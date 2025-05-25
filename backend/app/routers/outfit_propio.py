from io import BytesIO
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


router = APIRouter(prefix="/outfits")



@router.post("/generar")
async def generar_outfit(
    request: Request,
    titulo: str = Form(...),
    descripcion: Optional[str] = Form(None),
    ocasiones: List[OcasionEnum] = Form(..., alias="ocasiones[]"),
    temporadas: Optional[List[TemporadaEnum]] = Form([], alias="temporadas[]"),
    colores: Optional[List[ColorEnum]] = Form([], alias="colores[]"),
    db: Session = Depends(get_db)
):
    user = await obtener_usuario_actual(request, db)
    if not user:
        raise HTTPException(401, "Usuario no autenticado")

    outfit = await generar_outfit_propio(
        usuario=user,
        titulo=titulo,
        descripcion_generacion=descripcion,
        temporadas=temporadas,
        ocasiones=ocasiones,
        colores=colores,
    )
    if not outfit:
        raise HTTPException(404, "No se pudo generar outfit con esos filtros")

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
    if outfit.collage_key:
        outfit.imagen = generar_url_firmada(outfit.collage_key)

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

    # 2) Decodificar Base64 y recortar bordes transparentes
    try:
        raw = base64.b64decode(payload.imagen_base64)
        im = Image.open(BytesIO(raw)).convert("RGBA")
        bbox = im.getbbox()
        if bbox:
            im = im.crop(bbox)
        # (opcional) redimensionar a un ancho fijo, e.g. 800px de ancho:
        max_w = 800
        if im.width > max_w:
            ratio = max_w / im.width
            im = im.resize((max_w, int(im.height * ratio)), Image.Resampling.LANCZOS)
        buf = BytesIO()
        im.save(buf, format="PNG")
        png_bytes = buf.getvalue()
    except Exception:
        raise HTTPException(status_code=400, detail="imagen_base64 no es un PNG válido")

    key = await subir_imagen_s3_bytes(
        png_bytes,
        f"manual_{usuario.id}_{int(datetime.utcnow().timestamp())}.png"
    )

    # 3) Crear OutfitPropio
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
    db.flush()  # para obtener outfit.id antes de commit

    # 4) Crear OutfitItem para cada posición
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

    db.commit()
    db.refresh(outfit)

    # 5) Eager-load relaciones necesarias para la respuesta
    outfit = db.query(OutfitPropio) \
        .options(
            joinedload(OutfitPropio.articulos_propios),
            joinedload(OutfitPropio.items),
            joinedload(OutfitPropio.usuario),
        ) \
        .get(outfit.id)

    # 6) Firmar URLs
    for art in outfit.articulos_propios:
        art.urlFirmada = generar_url_firmada(art.foto)
    outfit.imagen = generar_url_firmada(outfit.collage_key) if outfit.collage_key else ""

    return outfit


@router.get("/stream", response_class=StreamingResponse)
async def obtener_outfits_stream(
    request: Request,
    ocasiones: List[OcasionEnum] = Query(None),
    temporadas: Optional[List[TemporadaEnum]] = Query(None),
    colores: Optional[List[ColorEnum]] = Query(None),
    db: Session = Depends(get_db),
):
    usuario_actual = await obtener_usuario_actual(request, db)
    if not usuario_actual:
        raise HTTPException(401, "Usuario no autenticado.")

    # Base query
    query = db.query(OutfitPropio).filter(OutfitPropio.usuario == usuario_actual)

    # filtros opcionales...
    if ocasiones:
        query = query.filter(or_(*[OutfitPropio.ocasiones.any(o) for o in ocasiones]))
    if temporadas:
        query = query.filter(or_(*[OutfitPropio.temporadas.any(t) for t in temporadas]))
    if colores:
        query = query.filter(or_(*[OutfitPropio.colores.any(c) for c in colores]))

    # **Eager-load** articulos_propios, items y usuario
    outfits = query.options(
        joinedload(OutfitPropio.articulos_propios),
        joinedload(OutfitPropio.items),
        joinedload(OutfitPropio.usuario),
    ).order_by(OutfitPropio.id.desc()).all()

    async def streamer():
        for outfit in outfits:
            # firmar URLs
            for art in outfit.articulos_propios:
                art.urlFirmada = generar_url_firmada(art.foto)
            outfit.imagen = generar_url_firmada(outfit.collage_key) if outfit.collage_key else ""

            # serializar con usuario e items
            schema = OutfitPropioConUsuarioResponse.from_orm(outfit).dict()
            yield json.dumps(schema) + "\n"

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

    # Trae todos los outfits de esos usuarios, ordenados por fecha desc.
    outfits = (
        db.query(OutfitPropio)
          .filter(OutfitPropio.usuario_id.in_(seguidos_ids))
          .options(
              joinedload(OutfitPropio.articulos_propios),
              joinedload(OutfitPropio.items),
              joinedload(OutfitPropio.usuario),
          )
          .order_by(OutfitPropio.fecha_creacion.desc())
          .offset(page * page_size)
          .limit(page_size)
          .all()
    )

    async def streamer():
        for outfit in outfits:
            # Firmar URLs de cada artículo
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
             joinedload(OutfitPropio.articulos_propios),
             joinedload(OutfitPropio.items),
             joinedload(OutfitPropio.usuario),
          )
          .order_by(OutfitPropio.fecha_creacion.desc())
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
    outfit = (
        db.query(OutfitPropio)
          .options(
             joinedload(OutfitPropio.articulos_propios),
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
    



