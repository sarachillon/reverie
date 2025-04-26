# backend/app/routers/articulo_propios.py
from fastapi import APIRouter, Depends, UploadFile, File, Form, HTTPException, Request
from sqlalchemy.orm import Session
from app.database.database import get_db
from app.models.models import *
from app.models.enummerations import *
from app.utils.s3 import subir_imagen_s3
from app.utils.auth import obtener_usuario_actual
from typing import List, Optional
import uuid
from app.schemas.articulo_propio import ArticuloCreate

router = APIRouter(prefix="/articulos-propios", tags=["Artículos Propios"])

@router.post("/")
async def crear_articulo(
    request: Request,
    nombre: str = Form(...),
    categoria: CategoriaEnum = Form(...),
    subcategoria_ropa: Optional[SubcategoriaRopaEnum] = Form(None),
    subcategoria_calzado: Optional[SubcategoriaCalzadoEnum] = Form(None),
    subcategoria_accesorios: Optional[SubcategoriaAccesoriosEnum] = Form(None),
    ocasiones: List[str] = Form(..., alias="ocasiones[]"),
    temporadas: List[str] = Form(..., alias="temporadas[]"),
    colores: List[str] = Form(..., alias="colores[]"),
    foto: UploadFile = File(...),
    db: Session = Depends(get_db),
):
    # Validación de subcategorías
    if categoria == CategoriaEnum.ROPA:
        if not subcategoria_ropa:
            raise HTTPException(status_code=400, detail="Subcategoría de ropa es obligatoria.")
        else:
            subcategoria=subcategoria_ropa.value
    elif categoria == CategoriaEnum.CALZADO:
        if not subcategoria_calzado:
            raise HTTPException(status_code=400, detail="Subcategoría de calzado es obligatoria.")
        else:
            subcategoria=subcategoria_calzado.value
    elif categoria == CategoriaEnum.ACCESORIOS:
        if not subcategoria_accesorios:
            raise HTTPException(status_code=400, detail="Subcategoría de accesorios es obligatoria.")
        else:
            subcategoria=subcategoria_accesorios.value
    
    # Subir imagen a S3
    try:
        imagen_key = await subir_imagen_s3(foto, foto.filename)  # Usamos la función para subir la imagen
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error al subir la imagen: {str(e)}")
    

    #usuario
    usuario_actual = await obtener_usuario_actual(request, db)
    if not usuario_actual:
        raise HTTPException(status_code=401, detail="Usuario no autenticado.")
    
    for ocasion in ocasiones:
        print(f"\n\n\n\n\n\n\nocasion: {ocasion}")
    for temporada in temporadas:
        print(f"temporada: {temporada}")
    for color in colores:
        print(f"color: {color}\n\n\n\n\n\n\n")


    ocasiones_enum = [OcasionEnum(o) for o in ocasiones]
    temporadas_enum = [TemporadaEnum(t) for t in temporadas]
    colores_enum = [ColorEnum(c) for c in colores]



    # Crear el nuevo artículo
    nuevo_articulo = ArticuloPropio(
        nombre=nombre,
        categoria=categoria,
        subcategoria=subcategoria,
        foto=imagen_key,
        ocasiones=ocasiones_enum,
        temporadas=temporadas_enum,
        colores=colores_enum,
        usuario=usuario_actual,
    )


    db.add(nuevo_articulo)
    db.commit()
    db.refresh(nuevo_articulo)

    return {"message": "Artículo guardado exitosamente", "articulo_id": nuevo_articulo.id}