from io import BytesIO
import traceback
from PIL import Image
import json
import base64
from enum import Enum
from typing import List, Optional
from fastapi import APIRouter, Body, Depends, Form, Request, HTTPException, Query
from fastapi.responses import JSONResponse, StreamingResponse
from pydantic import BaseModel
from sqlalchemy.orm import Session, joinedload, aliased
from sqlalchemy import or_, any_, func
from app.models.models import ArticuloPropio, OutfitItem, Usuario, OutfitPropio
from app.models.enummerations import TemporadaEnum, OcasionEnum, ColorEnum
from app.database.database import get_db
from app.utils.auth import obtener_usuario_actual
from app.utils.generacion_outfits import generar_outfit_propio
from app.utils.s3 import *
from app.schemas.outfit_propio import OutfitPropioConUsuarioResponse, OutfitPropioSimpleResponse, OutfitItemResponse
from app.schemas.user import UserOut
from datetime import datetime
from sqlalchemy.orm import joinedload
from sqlalchemy import or_


router = APIRouter(prefix="/outfits", tags=["Outfits"])



@router.post("/generar")
async def generar_outfit(
    request: Request,
    titulo: str = Form(...),
    descripcion: Optional[str] = Form(None),
    ocasiones: List[OcasionEnum] = Form(..., alias="ocasiones[]"),
    temporadas: Optional[List[TemporadaEnum]] = Form([], alias="temporadas[]"),
    colores: Optional[List[ColorEnum]] = Form([], alias="colores[]"),
    articulo_fijo_id: Optional[int] = Form(None, alias="articuloFijoId"),
    db: Session = Depends(get_db),
):
    user = await obtener_usuario_actual(request, db)
    if not user:
        raise HTTPException(401, "Usuario no autenticado")

    articulo_fijo = None
    print(f"articulo_fijo_id: {articulo_fijo_id}")
    if articulo_fijo_id is not None:
        articulo_fijo = next(
            (a for a in user.articulos_propios if a.id == articulo_fijo_id), None
        )
        if not articulo_fijo:
            raise HTTPException(404, "La prenda fija no pertenece al usuario")

    outfit = await generar_outfit_propio(
        usuario=user,
        titulo=titulo,
        descripcion_generacion=descripcion,
        temporadas=temporadas,
        ocasiones=ocasiones,
        colores=colores,
        articulo_fijo=articulo_fijo,            # ← se pasa
    )
    if not outfit:
        raise HTTPException(404, "No se pudo generar outfit con esos filtros")

    # ... resto igual (persistencia y URLs firmadas)

    db.add(outfit)
    db.commit()
    db.refresh(outfit)

    # precarga relaciones
    outfit = db.query(OutfitPropio)\
        .options(
            joinedload(OutfitPropio.articulos_propios),
            joinedload(OutfitPropio.items)
        )\
        .get(outfit.id)

    # urlFirmada para cada artículo e imagen
    for art in outfit.articulos_propios:
        art.urlFirmada = generar_url_firmada(art.foto)
    outfit.imagen = generar_url_firmada(outfit.collage_key) if outfit.collage_key else ""
    return outfit


class OutfitItemCreate(BaseModel):
    articulo_id: int
    x: float
    y: float
    scale: float
    rotation: float
    z_index: int

class ManualOutfitCreate(BaseModel):
    titulo: str
    ocasiones: List[OcasionEnum]
    items: List[OutfitItemCreate]
    imagen_base64: str


@router.post("/manual", response_model=OutfitPropioConUsuarioResponse, status_code=201)
async def crear_outfit_manual(
    request: Request,
    payload: ManualOutfitCreate = Body(...),
    db: Session = Depends(get_db),
):
    usuario = await obtener_usuario_actual(request, db)
    if not usuario:
        raise HTTPException(401, "Usuario no autenticado")

    # 1) Decodificar imagen y recortar...
    raw = base64.b64decode(payload.imagen_base64)
    im = Image.open(BytesIO(raw)).convert("RGBA")
    bbox = im.getbbox()
    if bbox: im = im.crop(bbox)
    if im.width > 800:
        ratio = 800 / im.width
        im = im.resize((800, int(im.height * ratio)), Image.Resampling.LANCZOS)
    buf = BytesIO(); im.save(buf, format="PNG")
    png_bytes = buf.getvalue()
    key = await subir_imagen_s3_bytes(
        png_bytes, f"manual_{usuario.id}_{int(datetime.utcnow().timestamp())}.png"
    )

    # 2) Crear instancia de OutfitPropio (sin commit aún)
    outfit = OutfitPropio(
        usuario=usuario,
        titulo=payload.titulo,
        descripcion_generacion="",
        fecha_creacion=datetime.utcnow(),
        ocasiones=payload.ocasiones,
        temporadas=[],
        colores=[],
        collage_key=key
    )
    db.add(outfit)
    db.flush()  # para que outfit.id ya exista

    # 3) Añadir cada OutfitItem
    for it in payload.items:
        db.add(OutfitItem(
            outfit_id=outfit.id,
            articulo_id=it.articulo_id,
            x=it.x,
            y=it.y,
            scale=it.scale,
            rotation=it.rotation,
            z_index=it.z_index,
        ))

    # 4) **Asignar los ArticuloPropio al outfit antes del commit**
    item_ids = [it.articulo_id for it in payload.items]
    articulos = db.query(ArticuloPropio).filter(ArticuloPropio.id.in_(item_ids)).all()
    outfit.articulos_propios = articulos

    # 5) Ahora sí: commit y refresh
    db.commit()
    db.refresh(outfit)

    # 6) Eager-load relaciones para la respuesta
    outfit = (
        db.query(OutfitPropio)
          .options(
              joinedload(OutfitPropio.articulos_propios)
                .joinedload(ArticuloPropio.usuario),
              joinedload(OutfitPropio.items),
              joinedload(OutfitPropio.usuario),
          )
          .get(outfit.id)
    )

    # 7) Firmar URLs
    for art in outfit.articulos_propios:
        art.urlFirmada = generar_url_firmada(art.foto)
    outfit.imagen = generar_url_firmada(outfit.collage_key) if outfit.collage_key else ""

    return outfit


    



@router.get("/stream", response_class=StreamingResponse)
async def obtener_outfits_stream(
    request: Request,
    user_id: Optional[int] = Query(None),
    ocasiones: Optional[List[OcasionEnum]] = Query(default=None),
    temporadas: Optional[List[TemporadaEnum]] = Query(default=None),
    colores: Optional[List[ColorEnum]] = Query(default=None),
    db: Session = Depends(get_db),
):
    usuario_actual = await obtener_usuario_actual(request, db)
    if not usuario_actual:
        raise HTTPException(status_code=401, detail="Usuario no autenticado.")

    id_usuario = user_id if user_id is not None else usuario_actual.id

    query = db.query(OutfitPropio).filter(OutfitPropio.usuario_id == id_usuario)

    if ocasiones:
        query = query.filter(OutfitPropio.ocasiones.op("&&")(ocasiones))
    if temporadas:
        query = query.filter(OutfitPropio.temporadas.op("&&")(temporadas))
    if colores:
        # expr para overlap en cualquier array
        overlap = lambda col_attr: col_attr.op("&&")(colores)

        query = query.filter(
            or_(
                overlap(OutfitPropio.colores),
                OutfitPropio.articulos_propios.any(
                    overlap(ArticuloPropio.colores)
                )
            )
        )

    outfits = query.options(
        joinedload(OutfitPropio.articulos_propios).joinedload(ArticuloPropio.usuario),
        joinedload(OutfitPropio.items),
    ).order_by(OutfitPropio.id.desc()).all()

    async def streamer():
        for outfit in outfits:
            for art in outfit.articulos_propios:
                art.urlFirmada = generar_url_firmada(art.foto)
            outfit.imagen = generar_url_firmada(outfit.collage_key) if outfit.collage_key else ""
            payload = OutfitPropioSimpleResponse.from_orm(outfit).dict()
            yield json.dumps(payload) + "\n"

    return StreamingResponse(streamer(), media_type="application/json")





@router.get("/count")
async def contar_outfits_usuario(
    request: Request,
    usuario_id: Optional[int] = None,
    db: Session = Depends(get_db)
):
    usuario_actual = await obtener_usuario_actual(request, db)
    if not usuario_actual:
        raise HTTPException(status_code=401, detail="Usuario no autenticado.")
    
    # Si no se especifica usuario_id, usa el usuario actual
    id_a_contar = usuario_id if usuario_id is not None else usuario_actual.id

    total = db.query(OutfitPropio).filter(OutfitPropio.usuario_id == id_a_contar).count()
    return {"total": total}


@router.get("/feed/seguidos", response_class=StreamingResponse)
async def feed_seguidos_stream(
    request: Request,
    page: int = Query(0, ge=0),
    page_size: int = Query(20, gt=0),
    db: Session = Depends(get_db)
):
    usuario_actual = await obtener_usuario_actual(request, db)
    if not usuario_actual:
        raise HTTPException(status_code=401, detail="Usuario no autenticado.")

    # IDs de los usuarios a los que sigue el usuario actual
    seguidos_ids = [u.id for u in usuario_actual.seguidos]

    outfits = (
        db.query(OutfitPropio).filter(OutfitPropio.usuario_id.in_(seguidos_ids))
          .options(
             joinedload(OutfitPropio.articulos_propios)
                .joinedload(ArticuloPropio.usuario),
             joinedload(OutfitPropio.items),
             joinedload(OutfitPropio.usuario),
          )
          .order_by(OutfitPropio.fecha_creacion.asc())
          .offset(page * page_size)
          .limit(page_size)
          .all()
    )

    async def streamer():
        for outfit in outfits:
            # Firmar URLs de artículos
            for art in outfit.articulos_propios:
                art.urlFirmada = generar_url_firmada(art.foto)
            # Firmar URL del collage
            outfit.imagen = (
                generar_url_firmada(outfit.collage_key)
                if outfit.collage_key
                else ""
            )
            # Serializar incluyendo usuario e items
            schema = OutfitPropioConUsuarioResponse.from_orm(outfit).dict()
            yield json.dumps(schema) + "\n"

    return StreamingResponse(streamer(), media_type="application/json")


@router.get("/{outfit_id}", response_model=OutfitPropioConUsuarioResponse)
async def obtener_outfit(
    outfit_id: int,
    db: Session = Depends(get_db),
):
    """
    Recupera un outfit completo por su ID, incluyendo:
    - articulos_propios (con su usuario)
    - items (posición, escala, rotación, z_index)
    - datos del usuario propietario
    - URL firmada de cada foto y del collage
    """
    # Carga el outfit y eager‐load de relaciones necesarias
    outfit = (
        db.query(OutfitPropio)
          .options(
             joinedload(OutfitPropio.articulos_propios)
                .joinedload(ArticuloPropio.usuario),
             joinedload(OutfitPropio.items),
             joinedload(OutfitPropio.usuario),
          )
          .filter(OutfitPropio.id == outfit_id)
          .first()
    )
    if not outfit:
        raise HTTPException(status_code=404, detail="Outfit no encontrado")

    # Firmar URLs de cada artículo
    for art in outfit.articulos_propios:
        art.urlFirmada = generar_url_firmada(art.foto)
    # Firmar URL del collage completo
    outfit.imagen = generar_url_firmada(outfit.collage_key) if outfit.collage_key else ""

    return outfit


@router.get("/feed/global", response_class=StreamingResponse)
async def feed_global_stream(
    request: Request,
    page: int = Query(0, ge=0),
    page_size: int = Query(20, gt=0),
    db: Session = Depends(get_db),
):
    usuario_actual = await obtener_usuario_actual(request, db)
    if not usuario_actual:
        raise HTTPException(status_code=401, detail="Usuario no autenticado.")

    # Traemos TODOS los outfits, sin filtro, ordenados por fecha descendente
    outfits = (
        db.query(OutfitPropio)
          .options(
             joinedload(OutfitPropio.articulos_propios)
                .joinedload(ArticuloPropio.usuario),
             joinedload(OutfitPropio.items),
             joinedload(OutfitPropio.usuario),
          )
          .order_by(OutfitPropio.fecha_creacion.asc())
          .offset(page * page_size)
          .limit(page_size)
          .all()
    )

    async def streamer():
        for outfit in outfits:
            # Firmar URLs de artículos
            for art in outfit.articulos_propios:
                art.urlFirmada = generar_url_firmada(art.foto)
            # Firmar URL del collage
            outfit.imagen = (
                generar_url_firmada(outfit.collage_key)
                if outfit.collage_key
                else ""
            )
            # Serializar incluyendo usuario e items
            schema = OutfitPropioConUsuarioResponse.from_orm(outfit).dict()
            yield json.dumps(schema) + "\n"

    return StreamingResponse(streamer(), media_type="application/json")


class ManualOutfitUpdate(BaseModel):
    items: List[OutfitItemCreate]
    imagen_base64: Optional[str] = None

@router.put("/editcollage/{outfit_id}", response_model=OutfitPropioConUsuarioResponse)
async def editar_outfit_manual(
    outfit_id: int,
    request: Request,
    payload: ManualOutfitUpdate = Body(...),
    db: Session = Depends(get_db),
):
    # Autenticación
    usuario = await obtener_usuario_actual(request, db)
    if not usuario:
        raise HTTPException(status_code=401, detail="Usuario no autenticado")

    # Buscamos el outfit y validamos propiedad
    outfit = (
        db.query(OutfitPropio)
          .filter(OutfitPropio.id == outfit_id, OutfitPropio.usuario_id == usuario.id)
          .first()
    )
    if not outfit:
        raise HTTPException(status_code=404, detail="Outfit no encontrado")

    # Procesar nueva imagen si se proporciona
    if payload.imagen_base64:
        try:
            raw = base64.b64decode(payload.imagen_base64)
            im = Image.open(BytesIO(raw)).convert("RGBA")
            # Recortar transparencia
            bbox = im.getbbox()
            if bbox:
                im = im.crop(bbox)
            # Redimensionar ancho max 800px
            max_w = 800
            if im.width > max_w:
                ratio = max_w / im.width
                im = im.resize((max_w, int(im.height * ratio)), Image.Resampling.LANCZOS)
            buf = BytesIO()
            im.save(buf, format="PNG")
            png_bytes = buf.getvalue()
        except Exception:
            raise HTTPException(status_code=400, detail="imagen_base64 no es un PNG válido")

        # Eliminar imagen anterior de S3
        if outfit.collage_key:
            try:
                await delete_imagen_s3(outfit.collage_key)
            except Exception:
                pass  # ignorar error al borrar antigua

        # Subir nueva
        timestamp = int(datetime.utcnow().timestamp())
        new_key = await subir_imagen_s3_bytes(
            png_bytes,
            f"manual_{usuario.id}_{outfit_id}_{timestamp}.png"
        )
        outfit.collage_key = new_key

    # Actualizar items: borrar existentes y crear nuevos
    db.query(OutfitItem).filter(OutfitItem.outfit_id == outfit_id).delete()
    for it in payload.items:
        db.add(OutfitItem(
            outfit_id=outfit_id,
            articulo_id=it.articulo_id,
            x=it.x,
            y=it.y,
            scale=it.scale,
            rotation=it.rotation,
            z_index=it.z_index,
        ))

    db.commit()
    db.refresh(outfit)

    # Eager load y firmar URLs
    outfit = (
        db.query(OutfitPropio)
          .options(joinedload(OutfitPropio.articulos_propios), joinedload(OutfitPropio.items))
          .get(outfit.id)
    )
    for art in outfit.articulos_propios:
        art.urlFirmada = generar_url_firmada(art.foto)
    outfit.imagen = generar_url_firmada(outfit.collage_key) if outfit.collage_key else ""

    return outfit

@router.get("/{outfit_id}", response_model=OutfitPropioConUsuarioResponse)
async def obtener_outfit(
    outfit_id: int,
    db: Session = Depends(get_db),
):
    outfit = (
        db.query(OutfitPropio)
          .options(
             joinedload(OutfitPropio.articulos_propios)
                .joinedload(ArticuloPropio.usuario),
             joinedload(OutfitPropio.items),
             joinedload(OutfitPropio.usuario),
          )
          .filter(OutfitPropio.id == outfit_id)
          .first()
    )
    if not outfit:
        raise HTTPException(404, "Outfit no encontrado")
    # firmar URLs
    for art in outfit.articulos_propios:
        art.urlFirmada = generar_url_firmada(art.foto)
    outfit.imagen = generar_url_firmada(outfit.collage_key) if outfit.collage_key else ""
    return outfit



class OutfitUpdateRequest(BaseModel):
    titulo: Optional[str] = None
    descripcion: Optional[str] = None
    ocasiones: Optional[List[OcasionEnum]] = None
    temporadas: Optional[List[TemporadaEnum]] = None
    colores: Optional[List[ColorEnum]] = None

@router.patch("/{outfit_id}", response_model=OutfitPropioConUsuarioResponse)
async def editar_outfit_parcial(
    outfit_id: int,
    request: Request,
    payload: OutfitUpdateRequest = Body(...),
    db: Session = Depends(get_db),
):
    usuario = await obtener_usuario_actual(request, db)
    if not usuario:
        raise HTTPException(status_code=401, detail="Usuario no autenticado")

    outfit = db.query(OutfitPropio).filter(
        OutfitPropio.id == outfit_id,
        OutfitPropio.usuario_id == usuario.id
    ).first()
    if not outfit:
        raise HTTPException(status_code=404, detail="Outfit no encontrado")

    # Solo actualiza los campos presentes
    if payload.titulo is not None:
        outfit.titulo = payload.titulo
    if payload.descripcion is not None:
        outfit.descripcion_generacion = payload.descripcion
    if payload.ocasiones is not None:
        outfit.ocasiones = payload.ocasiones
    if payload.temporadas is not None:
        outfit.temporadas = payload.temporadas
    if payload.colores is not None:
        outfit.colores = payload.colores

    db.commit()
    db.refresh(outfit)

    for art in outfit.articulos_propios:
        art.urlFirmada = generar_url_firmada(art.foto)
    outfit.imagen = generar_url_firmada(outfit.collage_key) if outfit.collage_key else ""
    return outfit



@router.delete("/{outfit_id}") 
async def eliminar_outfit(
    outfit_id: int,
    db: Session = Depends(get_db)
):
    outfit = db.query(OutfitPropio).filter(OutfitPropio.id == outfit_id).first()
    if not outfit:
        raise HTTPException(status_code=404, detail="Outfit no encontrado")

    try:
        await delete_imagen_s3(outfit.collage_key)
        db.delete(outfit)
        db.commit()
        return {"message": "Outfit eliminado correctamente"}
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=500, detail=f"Error al eliminar el outfit: {str(e)}")
    



