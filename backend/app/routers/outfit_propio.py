import base64
from enum import Enum
from typing import List, Optional
from fastapi import APIRouter, Depends, Form, Request, HTTPException
from sqlalchemy.orm import Session, joinedload
from app.models.models import Usuario, OutfitPropio
from app.models.enummerations import TemporadaEnum, OcasionEnum, ColorEnum
from app.database.database import get_db
from app.utils.auth import obtener_usuario_actual
from app.utils.generacion_outfits import generar_outfit_propietario
from app.utils.s3 import *
from app.schemas.outfit_propio import OutfitPropioResponse

router = APIRouter(prefix="/outfits", tags=["Outfits"])

@router.post("/generar")
async def generar_outfit(
    request: Request,
    titulo: str = Form(...),
    descripcion: Optional[str] = Form(None),
    ocasion: Optional[OcasionEnum] = Form(None),
    temporadas: Optional[List[TemporadaEnum]] = Form(None, alias="temporadas[]"),
    colores: Optional[List[ColorEnum]] = Form(None, alias="colores[]"),
    db: Session = Depends(get_db)
):
    usuario_actual: Usuario = await obtener_usuario_actual(request, db)
    if not usuario_actual:
        raise HTTPException(status_code=401, detail="Usuario no autenticado.")

    temporada = temporadas[0] if temporadas else None
    outfit = generar_outfit_propietario(
        usuario=usuario_actual,
        titulo=titulo,
        descripcion=descripcion,
        temporada=temporada,
        ocasion=ocasion,
        colores=colores
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

    return outfit



@router.get("/{outfit_id}", response_model=OutfitPropioResponse)
async def obtener_outfit(
    outfit_id: int,
    db: Session = Depends(get_db)
):
    outfit = db.query(OutfitPropio).filter(OutfitPropio.id == outfit_id).first()
    if not outfit:
        raise HTTPException(status_code=404, detail="Outfit no encontrado")

    return outfit
