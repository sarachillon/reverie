from typing import List, Optional
from fastapi import APIRouter, Body, Depends, Form, Request, HTTPException, Query
from sqlalchemy.orm import Session, joinedload, aliased
from sqlalchemy import or_, any_, func
from app.models.models import Coleccion, OutfitPropio
from app.models.associations import coleccion_outfit
from app.database.database import get_db
from app.utils.s3 import *
from app.schemas.outfit_propio import OutfitPropioConUsuarioResponse


router = APIRouter(prefix="/colecciones")


@router.post("/")
def crear_coleccion(
    nombre: str = Form(...),
    userId: int = Form(...),
    outfitId: Optional[int] = Form(None),
    db: Session = Depends(get_db)
):
    coleccion = Coleccion(nombre=nombre, propietario_id=userId)

    if outfitId is not None:
        outfit = db.query(OutfitPropio).filter(OutfitPropio.id == outfitId).first()
        if not outfit:
            raise HTTPException(status_code=404, detail="Outfit no encontrado")
        coleccion.outfits.append(outfit)

    db.add(coleccion)
    db.commit()
    db.refresh(coleccion)

    return {
        "id": coleccion.id,
        "nombre": coleccion.nombre,
        "propietario_id": coleccion.propietario_id,
        "outfit_ids": [o.id for o in coleccion.outfits]
    }




@router.get("/usuario/{user_id}")
def obtener_colecciones_usuario(user_id: int, db: Session = Depends(get_db)):
    colecciones = (
        db.query(Coleccion)
        .filter(Coleccion.propietario_id == user_id)
        .options(
            joinedload(Coleccion.outfits)
                .joinedload(OutfitPropio.usuario),
            joinedload(Coleccion.outfits)
                .joinedload(OutfitPropio.articulos_propios),
            joinedload(Coleccion.outfits)
                .joinedload(OutfitPropio.items)
        )
        .all()
    )

    resultado = []
    for coleccion in colecciones:
        outfits_validos = []
        for outfit in coleccion.outfits:
            # Validar relaciones necesarias
            if not outfit or not outfit.usuario or not outfit.collage_key:
                continue

            # Firmar imágenes
            for art in outfit.articulos_propios:
                art.urlFirmada = generar_url_firmada(art.foto)
            outfit.imagen = generar_url_firmada(outfit.collage_key)

            # Añadir outfit
            outfits_validos.append(
                OutfitPropioConUsuarioResponse.model_validate(outfit)
            )

        resultado.append({
            "id": coleccion.id,
            "nombre": coleccion.nombre,
            "outfits": outfits_validos
        })

    return resultado



@router.post("/{coleccion_id}/add_outfit")
def add_outfit_a_coleccion(
    coleccion_id: int,
    outfit_id: int = Form(...),
    db: Session = Depends(get_db)
):
    coleccion = db.query(Coleccion).filter(Coleccion.id == coleccion_id).first()
    if not coleccion:
        raise HTTPException(status_code=404, detail="Colección no encontrada")

    outfit = db.query(OutfitPropio).filter(OutfitPropio.id == outfit_id).first()
    if not outfit:
        raise HTTPException(status_code=404, detail="Outfit no encontrado")

    if outfit in coleccion.outfits:
        raise HTTPException(status_code=400, detail="El outfit ya está en la colección")

    coleccion.outfits.append(outfit)
    db.commit()

    return {"message": "Outfit añadido correctamente", "coleccion_id": coleccion_id, "outfit_id": outfit_id}


@router.delete("/{coleccion_id}/remove_outfit")
def remove_outfit_de_coleccion(
    coleccion_id: int,
    outfit_id: int = Query(...),
    db: Session = Depends(get_db)
):
    coleccion = db.query(Coleccion).filter(Coleccion.id == coleccion_id).first()
    if not coleccion:
        raise HTTPException(status_code=404, detail="Colección no encontrada")

    outfit = db.query(OutfitPropio).filter(OutfitPropio.id == outfit_id).first()
    if not outfit:
        raise HTTPException(status_code=404, detail="Outfit no encontrado")

    if outfit not in coleccion.outfits:
        raise HTTPException(status_code=400, detail="El outfit no está en la colección")

    coleccion.outfits.remove(outfit)
    db.commit()

    return {"message": "Outfit eliminado de la colección", "coleccion_id": coleccion_id, "outfit_id": outfit_id}


@router.delete("/{coleccion_id}")
def eliminar_coleccion(
    coleccion_id: int,
    db: Session = Depends(get_db)
):
    coleccion = db.query(Coleccion).filter(Coleccion.id == coleccion_id).first()
    if not coleccion:
        raise HTTPException(status_code=404, detail="Colección no encontrada")

    db.delete(coleccion)
    db.commit()

    return {"message": "Colección eliminada correctamente", "coleccion_id": coleccion_id}
