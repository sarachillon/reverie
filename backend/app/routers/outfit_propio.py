import traceback
import json
import base64
from enum import Enum
from typing import List, Optional
from fastapi import APIRouter, Depends, Form, Request, HTTPException, Query
from fastapi.responses import JSONResponse, StreamingResponse
from sqlalchemy.orm import Session, joinedload, aliased
from sqlalchemy import or_, any_, func
from app.models.models import Usuario, OutfitPropio
from app.models.enummerations import TemporadaEnum, OcasionEnum, ColorEnum
from app.database.database import get_db
from app.utils.auth import obtener_usuario_actual
from app.utils.generacion_outfits import generar_outfit_propio
from app.utils.s3 import *
from app.schemas.outfit_propio import OutfitPropioConUsuarioResponse, OutfitPropioSimpleResponse
from app.schemas.user import UserOut


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
    usuario_actual: Usuario = await obtener_usuario_actual(request, db)
    if not usuario_actual:
        raise HTTPException(status_code=401, detail="Usuario no autenticado.")
    
    outfit = await generar_outfit_propio(
        usuario=usuario_actual,
        titulo=titulo,
        descripcion_generacion=descripcion,
        temporadas=temporadas,
        ocasiones=ocasiones,
        colores=colores,
    )

    if not outfit:
        raise HTTPException(status_code=404, detail="No se ha podido generar un outfit con los filtros proporcionados.")

    db.add(outfit)
    db.commit()
    db.refresh(outfit)

    # Volver a cargar con los artículos asociados
    outfit = db.query(OutfitPropio)\
        .options(joinedload(OutfitPropio.articulos_propios))\
        .filter(OutfitPropio.id == outfit.id).first()

    # Aquí inyectamos las imágenes en base64 en cada artículo
    for articulo in outfit.articulos_propios:
        imagen_bytes = await get_imagen_s3(articulo.foto)
        articulo.imagen = base64.b64encode(imagen_bytes).decode("utf-8")

    # Añadir imagen del collage 
    if outfit.collage_key:
        try:
            collage_bytes = await get_imagen_s3(outfit.collage_key)
            outfit.imagen = base64.b64encode(collage_bytes).decode("utf-8")
        except Exception as e:
            print(f"Error al obtener collage: {e}")
            outfit.imagen = ""

    return outfit



@router.get("/stream", response_class=StreamingResponse)
async def obtener_outfits_stream(
    request: Request,
    ocasiones: List[OcasionEnum] = Query(None),
    temporadas: Optional[List[TemporadaEnum]] = Query(None),
    colores: Optional[List[ColorEnum]] = Query(None),
    db: Session = Depends(get_db),
):
    try:
        usuario_actual = await obtener_usuario_actual(request, db)
        if not usuario_actual:
            raise HTTPException(status_code=401, detail="Usuario no autenticado.")

        query = db.query(OutfitPropio).filter(OutfitPropio.usuario_id == usuario_actual.id)

        if ocasiones:
            query = query.filter(or_(*[OutfitPropio.ocasiones.any(t) for t in ocasiones]))
        if temporadas:
            query = query.filter(or_(*[OutfitPropio.temporadas.any(t) for t in temporadas]))
        if colores:
            query = query.filter(or_(*[OutfitPropio.colores.any(t) for t in colores]))

        outfits = query.options(joinedload(OutfitPropio.articulos_propios)).order_by(OutfitPropio.id.desc()).all()

        async def outfit_generator():
            for outfit in outfits:
                try:
                    # Añadir imagen a cada artículo
                    for articulo in outfit.articulos_propios:
                        try:
                            imagen_bytes = await get_imagen_s3(articulo.foto)
                            articulo.imagen = base64.b64encode(imagen_bytes).decode("utf-8")
                        except Exception as e_img:
                            print(f"⚠️  Error al obtener imagen del artículo {articulo.id}: {e_img}")
                            articulo.imagen = ""

                    # Añadir imagen del collage
                    imagen_collage = ""
                    if outfit.collage_key:
                        try:
                            collage_bytes = await get_imagen_s3(outfit.collage_key)
                            imagen_collage = base64.b64encode(collage_bytes).decode("utf-8")
                        except Exception as e_col:
                            print(f"⚠️  Error al obtener collage {outfit.collage_key}: {e_col}")

                    setattr(outfit, "imagen", imagen_collage)
                    ###
                    schema = OutfitPropioSimpleResponse.from_orm(outfit).dict()
                    
                    yield json.dumps(schema) + "\n"

                except Exception as e_outfit:
                    traceback.print_exc()

        return StreamingResponse(outfit_generator(), media_type="application/json")

    except Exception as e:
        traceback.print_exc()
        raise HTTPException(status_code=500, detail="Error interno al procesar outfits.")




"""@router.get("/feed")
async def obtener_feed_outfits(
    request: Request,
    page: int = Query(0, ge=0),
    page_size: int = Query(6, gt=0),
    db: Session = Depends(get_db),
):
    try:
        usuario_actual = await obtener_usuario_actual(request, db)
        if not usuario_actual:
            raise HTTPException(status_code=401, detail="Usuario no autenticado.")

        # IDs de usuarios seguidos
        seguidos_ids = [rel.id_seguido for rel in usuario_actual.seguidos]

        Seguidor = aliased(Usuario)

        subquery = (
            db.query(Usuario.id)
            .join(Seguidor, Usuario.seguidores)  
            .group_by(Usuario.id)
            .order_by(Usuario.id.desc())
            .filter(Usuario.id.notin_(seguidos_ids + [usuario_actual.id]))
            .limit(5)
            .subquery()
        )


        ids_finales = seguidos_ids + [id for (id,) in db.query(subquery).all()]

        # Consulta de outfits
        outfits = (
            db.query(OutfitPropio)
            .filter(OutfitPropio.usuario_id.in_(ids_finales))
            .order_by(OutfitPropio.fecha_creacion.desc())
            .offset(page * page_size)
            .limit(page_size)
            .all()
        )

        

        resultados = []
        for outfit in outfits:
            # Añadir imagen a cada artículo
            for articulo in outfit.articulos_propios:
                try:
                    imagen_bytes = await get_imagen_s3(articulo.foto)
                    articulo.imagen = base64.b64encode(imagen_bytes).decode("utf-8")
                except:
                    articulo.imagen = ""

            # Añadir imagen del collage
            try:
                if outfit.collage_key:
                    collage_bytes = await get_imagen_s3(outfit.collage_key)
                    outfit.imagen = base64.b64encode(collage_bytes).decode("utf-8")
                else:
                    outfit.imagen = ""
            except:
                outfit.imagen = ""

            resultados.append(OutfitPropioResponse.from_orm(outfit))

        return resultados


    except Exception as e:
        return JSONResponse(status_code=500, content={"detail": str(e)})"""
    

@router.get("/feed/seguidos", response_class=StreamingResponse)
async def feed_seguidos_stream(
    request: Request,
    page: int = Query(0, ge=0),
    page_size: int = Query(20, gt=0),
    db: Session = Depends(get_db)
):
    try:
        usuario_actual = await obtener_usuario_actual(request, db)
        if not usuario_actual:
            raise HTTPException(status_code=401, detail="Usuario no autenticado.")

        seguidos_ids = [rel.id_seguido for rel in usuario_actual.seguidos]

        query = db.query(OutfitPropio)\
            .filter(OutfitPropio.usuario_id.in_(seguidos_ids))\
            .order_by(OutfitPropio.fecha_creacion.desc())\
            .offset(page * page_size)\
            .limit(page_size)

        outfits = query.options(joinedload(OutfitPropio.articulos_propios)).all()

        async def stream():
            for outfit in outfits:
                for articulo in outfit.articulos_propios:
                    try:
                        imagen_bytes = await get_imagen_s3(articulo.foto)
                        articulo.imagen = base64.b64encode(imagen_bytes).decode("utf-8")
                    except:
                        articulo.imagen = ""
                try:
                    if outfit.collage_key:
                        collage_bytes = await get_imagen_s3(outfit.collage_key)
                        outfit.imagen = base64.b64encode(collage_bytes).decode("utf-8")
                    else:
                        outfit.imagen = ""
                except:
                    outfit.imagen = ""
                schema = OutfitPropioConUsuarioResponse.from_orm(outfit).dict(exclude={"usuario"})
                schema["usuario"] = UserOut.from_orm(outfit.usuario).dict()
                yield json.dumps(schema) + "\n"

        return StreamingResponse(stream(), media_type="application/json")

    except Exception as e:
        return JSONResponse(status_code=500, content={"detail": str(e)})



@router.get("/feed/global", response_class=StreamingResponse)
async def feed_global_stream(
    request: Request,
    page: int = Query(0, ge=0),
    page_size: int = Query(20, gt=0),
    db: Session = Depends(get_db)
):
    try:
        usuario_actual = await obtener_usuario_actual(request, db)
        if not usuario_actual:
            raise HTTPException(status_code=401, detail="Usuario no autenticado.")

        seguidos_ids = [rel.id_seguido for rel in usuario_actual.seguidos]

        Seguidor = aliased(Usuario)
        subquery = (
            db.query(Usuario.id)
            .join(Seguidor, Usuario.seguidores)
            .group_by(Usuario.id)
            .order_by(func.count().desc())
            .filter(Usuario.id.notin_(seguidos_ids + [usuario_actual.id]))
            .limit(20)
            .subquery()
        )

        ids_recomendados = [id for (id,) in db.query(subquery).all()]

        query = db.query(OutfitPropio)\
            .filter(OutfitPropio.usuario_id.in_(ids_recomendados))\
            .order_by(OutfitPropio.fecha_creacion.desc())\
            .offset(page * page_size)\
            .limit(page_size)

        #outfits = query.options(joinedload(OutfitPropio.articulos_propios)).all()
        outfits = query.options( joinedload(OutfitPropio.articulos_propios),joinedload(OutfitPropio.usuario)).all()

        async def stream():
            for outfit in outfits:
                # Cargar imagen del usuario si tiene foto_perfil
                if outfit.usuario and outfit.usuario.foto_perfil:
                    try:
                        perfil_bytes = await get_imagen_s3(outfit.usuario.foto_perfil)
                        outfit.usuario.foto_perfil = base64.b64encode(perfil_bytes).decode("utf-8")
                    except:
                        outfit.usuario.foto_perfil = None

                for articulo in outfit.articulos_propios:
                    try:
                        imagen_bytes = await get_imagen_s3(articulo.foto)
                        articulo.imagen = base64.b64encode(imagen_bytes).decode("utf-8")
                    except:
                        articulo.imagen = ""
                try:
                    if outfit.collage_key:
                        collage_bytes = await get_imagen_s3(outfit.collage_key)
                        outfit.imagen = base64.b64encode(collage_bytes).decode("utf-8")
                    else:
                        outfit.imagen = ""
                except:
                    outfit.imagen = ""
                schema = OutfitPropioConUsuarioResponse.from_orm(outfit).dict(exclude={"usuario"})
                schema["usuario"] = UserOut.from_orm(outfit.usuario).dict()
                yield json.dumps(schema) + "\n"



        return StreamingResponse(stream(), media_type="application/json")

    except Exception as e:
        return JSONResponse(status_code=500, content={"detail": str(e)})




@router.get("/{outfit_id}", response_model=OutfitPropioSimpleResponse)
async def obtener_outfit(
    outfit_id: int,
    db: Session = Depends(get_db)
):
    outfit = db.query(OutfitPropio).filter(OutfitPropio.id == outfit_id).first()
    if not outfit:
        raise HTTPException(status_code=404, detail="Outfit no encontrado")

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
    

