# backend/app/routers/articulo_propios.py
from fastapi import APIRouter, Depends, UploadFile, File, Form, HTTPException, Request
from sqlalchemy.orm import Session
from sqlalchemy import and_, or_
from app.database.database import get_db
from app.models.models import *
from app.models.enummerations import *
from app.utils.s3 import *
from app.utils.auth import obtener_usuario_actual
from typing import List, Optional, AsyncGenerator
import uuid
from app.schemas.articulo_propio import *
from fastapi.responses import StreamingResponse
import json
import base64

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




# Obtener todos los artículos propios del usuario autenticado
@router.get("/",  response_model=List[ArticuloPropioConImagen])
async def obtener_articulos_propios(
    request: Request,
    categoria: Optional[CategoriaEnum] = None,
    subcategoria: Optional[str] = None,
    ocasiones: Optional[List[OcasionEnum]] = None,
    temporadas: Optional[List[TemporadaEnum]] = None,
    colores: Optional[List[ColorEnum]] = None,
    db: Session = Depends(get_db),
):
    usuario_actual = await obtener_usuario_actual(request, db)
    if not usuario_actual:
        raise HTTPException(status_code=401, detail="Usuario no autenticado.")
    
    query = db.query(ArticuloPropio).filter(ArticuloPropio.usuario_id == usuario_actual.id)

    if categoria:
        query = query.filter(ArticuloPropio.categoria == categoria)
        if subcategoria:
            query = query.filter(ArticuloPropio.subcategoria == subcategoria)
    elif subcategoria:
        raise HTTPException(status_code=400, detail="No se puede filtrar por subcategoría sin filtrar por categoría.")

    if ocasiones:
        query = query.filter(or_(*[ArticuloPropio.ocasiones.any(ocasion) for ocasion in ocasiones]))

    if temporadas:
        query = query.filter(or_(*[ArticuloPropio.temporadas.any(temporada) for temporada in temporadas]))

    if colores:
        query = query.filter(or_(*[ArticuloPropio.colores.any(color) for color in colores]))

    articulos = query.all()


    # Obtener las imágenes de S3 para cada artículo
    articulos_con_imagenes = []
    for articulo in articulos:
        try:
            print(f"Fetching image for key: {articulo.foto}") 
            imagen_bytes = await get_imagen_s3(articulo.foto)
            imagen_base64 = base64.b64encode(imagen_bytes).decode('utf-8')
            articulos_con_imagenes.append(ArticuloPropioConImagen(
                **articulo.__dict__,
                imagen=imagen_base64
            ))
        except Exception as e:
            print(f"Error fetching image for {articulo.foto}: {e}") # Log the specific error
            raise HTTPException(status_code=500, detail=f"Error al obtener la imagen: {str(e)}")

    return articulos_con_imagenes





# Obtener  los artículos propios del usuario autenticado de uno en uno
@router.get("/stream", response_class=StreamingResponse)
async def obtener_articulos_propios_stream(
    request: Request,
    categoria: Optional[CategoriaEnum] = None,
    subcategoria: Optional[str] = None,
    ocasiones: Optional[List[OcasionEnum]] = None,
    temporadas: Optional[List[TemporadaEnum]] = None,
    colores: Optional[List[ColorEnum]] = None,
    db: Session = Depends(get_db),
):
    usuario_actual = await obtener_usuario_actual(request, db)
    if not usuario_actual:
        raise HTTPException(status_code=401, detail="Usuario no autenticado.")
    
    query = db.query(ArticuloPropio).filter(ArticuloPropio.usuario_id == usuario_actual.id)

    if categoria:
        query = query.filter(ArticuloPropio.categoria == categoria)
        if subcategoria:
            query = query.filter(ArticuloPropio.subcategoria == subcategoria)
    elif subcategoria:
        raise HTTPException(status_code=400, detail="No se puede filtrar por subcategoría sin filtrar por categoría.")

    if ocasiones:
        query = query.filter(or_(*[ArticuloPropio.ocasiones.any(ocasion) for ocasion in ocasiones]))

    if temporadas:
        query = query.filter(or_(*[ArticuloPropio.temporadas.any(temporada) for temporada in temporadas]))

    if colores:
        query = query.filter(or_(*[ArticuloPropio.colores.any(color) for color in colores]))

    articulos = query.all()

    async def articulo_generator():
        for articulo in articulos:
            try:
                print(f"Fetching image for key: {articulo.foto}")
                imagen_bytes = await get_imagen_s3(articulo.foto)
                imagen_base64 = base64.b64encode(imagen_bytes).decode('utf-8')
                articulo_con_imagen = ArticuloPropioConImagen(
                    **articulo.__dict__,
                    imagen=imagen_base64
                )
                # Serializamos el artículo a JSON
                yield json.dumps(articulo_con_imagen.dict()) + "\n"
            except Exception as e:
                print(f"Error fetching image for {articulo.foto}: {e}")
                raise HTTPException(status_code=500, detail=f"Error al obtener la imagen: {str(e)}")

    return StreamingResponse(articulo_generator(), media_type="application/json")








# Obtener un artículo propio por su nombre
@router.get("/{nombre}", response_model=ArticuloCreate)
async def obtener_articulo_por_nombre(
    nombre: str,
    request: Request,
    db: Session = Depends(get_db),
):
    usuario_actual = await obtener_usuario_actual(request, db)
    if not usuario_actual:
        raise HTTPException(status_code=401, detail="Usuario no autenticado.")

    articulo = db.query(ArticuloPropio).filter(
        ArticuloPropio.usuario_id == usuario_actual.id,
        ArticuloPropio.nombre == nombre
    ).first()

    if not articulo:
        raise HTTPException(status_code=404, detail="Artículo no encontrado.")

    return articulo
