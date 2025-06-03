# backend/app/routers/articulo_propios.py
import os
from fastapi import APIRouter, Depends, Path, UploadFile, File, Form, HTTPException, Request, Query
from fastapi.responses import JSONResponse, StreamingResponse
from sqlalchemy import or_, any_, func
from sqlalchemy.orm import Session
from sqlalchemy.dialects.postgresql import array
from app.database.database import get_db
from app.models.models import *
from app.models.enummerations import *
from app.utils.s3 import *
from app.utils.auth import obtener_usuario_actual
from app.utils.inferir_estilo import *
from app.schemas.articulo_propio import *
from app.utils.remove_background import quitar_fondo_imagen  
from typing import List, Optional
import json
import base64
from PIL import Image
from sqlalchemy.orm import joinedload


router = APIRouter(prefix="/articulos-propios", tags=["Artículos Propios"])


# Crea un artículo propio partiendo de una imagen ya existente
@router.post("/from-key")
async def crear_articulo_desde_key(
    request: Request,
    key_imagen_original: str = Form(..., alias="keyImagen"),

    usuario: int = Form(..., alias="usuario"),
    nombre: str = Form(...),

    categoria: CategoriaEnum = Form(...),
    subcategoria_ropa: Optional[SubcategoriaRopaEnum] = Form(None),
    subcategoria_calzado: Optional[SubcategoriaCalzadoEnum] = Form(None),
    subcategoria_accesorios: Optional[SubcategoriaAccesoriosEnum] = Form(None),

    ocasiones: List[str] = Form(..., alias="ocasiones[]"),
    temporadas: List[str] = Form(..., alias="temporadas[]"),
    colores: List[str] = Form(..., alias="colores[]"),

    estilo: EstiloEnum = Form(...),
    formalidad: int = Form(...),

    db: Session = Depends(get_db),
):
    """
    Crea un ArticuloPropio tomando la imagen ya subida a S3 (keyImagen) y
    copiándola con un nombre único.  Todos los atributos se reciben por formulario;
    no se infiere estilo ni formalidad.
    """

    # ───────── Validación de subcategoría ─────────
    if categoria == CategoriaEnum.ROPA:
        if not subcategoria_ropa:
            raise HTTPException(status_code=400, detail="Subcategoría de ropa es obligatoria.")
        subcategoria = SubcategoriaRopaEnum(subcategoria_ropa).name
    elif categoria == CategoriaEnum.CALZADO:
        if not subcategoria_calzado:
            raise HTTPException(status_code=400, detail="Subcategoría de calzado es obligatoria.")
        subcategoria = SubcategoriaCalzadoEnum(subcategoria_calzado).name
    elif categoria == CategoriaEnum.ACCESORIOS:
        if not subcategoria_accesorios:
            raise HTTPException(status_code=400, detail="Subcategoría de accesorios es obligatoria.")
        subcategoria = SubcategoriaAccesoriosEnum(subcategoria_accesorios).name

    # ───────── Copiar / renombrar la imagen ───────
    try:
        original_bytes = await get_imagen_s3(key_imagen_original)

        nuevo_nombre  = generar_nombre_unico(os.path.basename(key_imagen_original))
        imagen_key    = await subir_imagen_s3_bytes(original_bytes, nuevo_nombre)

    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error al procesar la imagen: {e}")


    # ───────── Mapear listas a enums ─────────
    try:
        ocasiones_enum  = [OcasionEnum(o)   for o in ocasiones]
        temporadas_enum = [TemporadaEnum(t) for t in temporadas]
        colores_enum    = [ColorEnum(c)     for c in colores]
    except ValueError as e:
        raise HTTPException(status_code=400, detail=f"Valor inválido en ocasiones/temporadas/colores: {e}")

    # ───────── Crear artículo ─────────
    usuario = db.get(Usuario, usuario)
    if not usuario:
        raise HTTPException(status_code=404, detail="Usuario no encontrado")
    
    nuevo_articulo = ArticuloPropio(
        nombre       = nombre,
        categoria    = categoria,
        subcategoria = subcategoria,
        foto         = imagen_key,
        ocasiones    = ocasiones_enum,
        temporadas   = temporadas_enum,
        colores      = colores_enum,
        usuario      = usuario,
        estilo       = estilo,        
        formalidad   = formalidad,   
    )

    db.add(nuevo_articulo)
    db.commit()
    db.refresh(nuevo_articulo)

    return {"message": "Artículo guardado exitosamente", "articulo_id": nuevo_articulo.id}



# Crear un nuevo artículo propio
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
            subcategoria=SubcategoriaRopaEnum(subcategoria_ropa).name
    elif categoria == CategoriaEnum.CALZADO:
        if not subcategoria_calzado:
            raise HTTPException(status_code=400, detail="Subcategoría de calzado es obligatoria.")
        else:
            subcategoria=SubcategoriaCalzadoEnum(subcategoria_calzado).name
    elif categoria == CategoriaEnum.ACCESORIOS:
        if not subcategoria_accesorios:
            raise HTTPException(status_code=400, detail="Subcategoría de accesorios es obligatoria.")
        else:
            subcategoria=SubcategoriaAccesoriosEnum(subcategoria_accesorios).name
    
    # Subir imagen a S3
    try:
        original_bytes = await foto.read()
        imagen_key = await subir_imagen_s3_bytes(original_bytes, f"{foto.filename.split('.')[0]}.png")

        imagen_pil = Image.open(io.BytesIO(original_bytes)).convert("RGB")
        estilo_inferido = inferir_estilo_desde_imagen(imagen_pil)
        estilo = EstiloEnum(estilo_inferido)
        formalidad = inferir_formalidad_desde_estilo(estilo_inferido)
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error al subir la imagen: {str(e)}")
    

    usuario_actual = await obtener_usuario_actual(request, db)
    if not usuario_actual:
        raise HTTPException(status_code=401, detail="Usuario no autenticado.")

    ocasiones_enum = [OcasionEnum(o) for o in ocasiones]
    temporadas_enum = [TemporadaEnum(t) for t in temporadas]
    colores_enum = [ColorEnum(c) for c in colores]



    # Crear el nuevo artículo propio
    nuevo_articulo = ArticuloPropio(
        nombre=nombre,
        categoria=categoria,
        subcategoria=subcategoria,
        foto=imagen_key,
        ocasiones=ocasiones_enum,
        temporadas=temporadas_enum,
        colores=colores_enum,
        usuario=usuario_actual,
        estilo = estilo,
        formalidad=formalidad,
    )

    db.add(nuevo_articulo)
    db.commit()
    db.refresh(nuevo_articulo)

    return {"message": "Artículo guardado exitosamente", "articulo_id": nuevo_articulo.id}





@router.get("/stream", response_class=StreamingResponse)
async def obtener_articulos_propios_stream(
    request: Request,
    usuario_id: Optional[int] = None,
    categoria: Optional[CategoriaEnum] = None,
    subcategoria: Optional[str] = None,
    ocasiones: Optional[List[OcasionEnum]] = Query(None),
    temporadas: Optional[List[TemporadaEnum]] = Query(None),
    colores: Optional[List[ColorEnum]] = Query(None),
    db: Session = Depends(get_db),
):
    if usuario_id:
        # Si se especifica usuario_id => usa ese
        query = db.query(ArticuloPropio).filter(ArticuloPropio.usuario_id == usuario_id)
    else:
        # Si no se especifica => usa el usuario autenticado
        usuario_actual = await obtener_usuario_actual(request, db)
        if not usuario_actual:
            raise HTTPException(status_code=401, detail="Usuario no autenticado.")
        query = db.query(ArticuloPropio).filter(ArticuloPropio.usuario_id == usuario_actual.id)
    
    articulos = query.options(joinedload(ArticuloPropio.usuario)).order_by(ArticuloPropio.id.desc()).all()

    if not articulos:
        return JSONResponse(content=[])

    if categoria:
        query = query.filter(ArticuloPropio.categoria == categoria)
        if subcategoria:
            query = query.filter(ArticuloPropio.subcategoria == subcategoria)
    elif subcategoria:
        raise HTTPException(status_code=400, detail="No se puede filtrar por subcategoría sin filtrar por categoría.")

    if ocasiones:
        query = query.filter(or_(*[ArticuloPropio.ocasiones.any(t) for t in ocasiones]))

    if temporadas:
        query = query.filter(or_(*[ArticuloPropio.temporadas.any(t) for t in temporadas]))

    if colores:
        query = query.filter(or_(*[ArticuloPropio.colores.any(t) for t in colores]))

    articulos = query.options(joinedload(ArticuloPropio.usuario)).order_by(ArticuloPropio.id.desc()).all()

    async def articulo_generator():
        for articulo in articulos:
            try:
                url = generar_url_firmada(articulo.foto)
                schema = ArticuloPropioConUrl.from_orm(articulo).dict()
                schema["urlFirmada"] = url
                yield json.dumps(schema) + "\n"
            except Exception as e:
                print(f"Error generando URL para {articulo.foto}: {e}")
                raise HTTPException(status_code=500, detail=f"Error al generar la URL de la imagen")

    return StreamingResponse(articulo_generator(), media_type="application/json")



@router.get("/count")
async def contar_articulos_usuario(
    request: Request,
    usuario_id: Optional[int] = None,
    categoria: Optional[CategoriaEnum] = None,
    db: Session = Depends(get_db),
):
    usuario_actual = await obtener_usuario_actual(request, db)
    if not usuario_actual:
        raise HTTPException(status_code=401, detail="Usuario no autenticado.")
    
    id_objetivo = usuario_id or usuario_actual.id

    query = db.query(ArticuloPropio).filter(ArticuloPropio.usuario_id == id_objetivo)

    if categoria:
        query = query.filter(ArticuloPropio.categoria == categoria)

    total = query.count()
    return {"total": total}


@router.get("/all-with-url", response_model=List[ArticuloPropioConUrl])
async def obtener_todos_los_articulos_con_url(
    db: Session = Depends(get_db)
):
    """
    Devuelve todos los artículos de la BD (de cualquier usuario), cada uno con su urlFirmada.
    """
    articulos = db.query(ArticuloPropio).options(joinedload(ArticuloPropio.usuario)).all()
    result = []
    for articulo in articulos:
        try:
            url = generar_url_firmada(articulo.foto)
        except Exception as e:
            url = ""
        schema = ArticuloPropioConUrl.from_orm(articulo)
        result.append(schema.copy(update={"urlFirmada": url}))
    return result



@router.get("/{articulo_id}", response_model=ArticuloPropioConUrl)
async def obtener_articulo_por_id(
    request: Request,
    articulo_id: int = Path(..., description="ID del artículo propio"),
    db: Session = Depends(get_db),
):
    usuario_actual = await obtener_usuario_actual(request, db)
    if not usuario_actual:
        raise HTTPException(status_code=401, detail="Usuario no autenticado.")

    articulo = (
        db.query(ArticuloPropio)
          .filter(ArticuloPropio.id == articulo_id, ArticuloPropio.usuario_id == usuario_actual.id)
          .first()
    )
    if not articulo:
        raise HTTPException(status_code=404, detail="Artículo no encontrado.")

    try:
        url = generar_url_firmada(articulo.foto)
        if not url:
            raise ValueError("URL generada vacía")
    except Exception as e:
        url = ""  # Devuelve una cadena vacía si falla la generación
        print(f"Error generando URL para artículo {articulo_id}: {e}")


    schema = ArticuloPropioConUrl.from_orm(articulo)
    return schema.copy(update={"urlFirmada": url})

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


# Eliminar un artículo propio por su ID
@router.delete("/{articulo_id}")
async def eliminar_articulo(
    articulo_id: int,
    request: Request,
    db: Session = Depends(get_db),
):
    usuario_actual = await obtener_usuario_actual(request, db)
    if not usuario_actual:
        raise HTTPException(status_code=401, detail="Usuario no autenticado.")

    articulo = db.query(ArticuloPropio).filter(
        ArticuloPropio.usuario_id == usuario_actual.id,
        ArticuloPropio.id == articulo_id
    ).first()

    if not articulo:
        raise HTTPException(status_code=404, detail="Artículo no encontrado.")

    # Eliminar la imagen de S3
    try:
        await delete_imagen_s3(articulo.foto)
    except Exception as e:
        print(f"Advertencia: error al eliminar imagen S3: {e}")
        # Continuamos aunque falle S3

    try:
        # Eliminar outfits que contengan este artículo
        outfits_a_eliminar = list(articulo.outfits_propios)
        for outfit in outfits_a_eliminar:
            await delete_imagen_s3(outfit.collage_key)
            db.delete(outfit)

        db.delete(articulo)
        db.commit()

    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error al eliminar el artículo de la base de datos: {str(e)}")


    return {"message": "Artículo eliminado exitosamente"}



@router.post("/editar/{articulo_id}")
async def editar_articulo(
    articulo_id: int,
    request: Request,
    nombre: Optional[str] = Form(None),
    categoria: Optional[CategoriaEnum] = Form(None),
    subcategoria_ropa: Optional[SubcategoriaRopaEnum] = Form(None),
    subcategoria_calzado: Optional[SubcategoriaCalzadoEnum] = Form(None),
    subcategoria_accesorios: Optional[SubcategoriaAccesoriosEnum] = Form(None),
    ocasiones: Optional[List[str]] = Form(None, alias="ocasiones[]"),
    temporadas: Optional[List[str]] = Form(None, alias="temporadas[]"),
    colores: Optional[List[str]] = Form(None, alias="colores[]"),
    foto: Optional[UploadFile] = File(None),
    db: Session = Depends(get_db),
):
    usuario_actual = await obtener_usuario_actual(request, db)
    if not usuario_actual:
        raise HTTPException(status_code=401, detail="Usuario no autenticado.")

    articulo = db.query(ArticuloPropio).filter_by(id=articulo_id, usuario_id=usuario_actual.id).first()
    if not articulo:
        raise HTTPException(status_code=404, detail="Artículo no encontrado.")

    if nombre is not None:
        articulo.nombre = nombre

    if categoria is not None:
        articulo.categoria = categoria
        if categoria == CategoriaEnum.ROPA and subcategoria_ropa:
            articulo.subcategoria = subcategoria_ropa.name
        elif categoria == CategoriaEnum.CALZADO and subcategoria_calzado:
            articulo.subcategoria = subcategoria_calzado.name
        elif categoria == CategoriaEnum.ACCESORIOS and subcategoria_accesorios:
            articulo.subcategoria = subcategoria_accesorios.name

    if ocasiones is not None:
        articulo.ocasiones = [OcasionEnum(o) for o in ocasiones]

    if temporadas is not None:
        articulo.temporadas = [TemporadaEnum(t) for t in temporadas]

    if colores is not None:
        articulo.colores = [ColorEnum(c) for c in colores]
    import time

    if foto is not None:
        original_bytes = await foto.read()
        imagen_sin_fondo = quitar_fondo_imagen(original_bytes)
        nombre_unico = f"{foto.filename.split('.')[0]}_{int(time.time() * 1000)}.png"
        imagen_key = await subir_imagen_s3_bytes(imagen_sin_fondo, f"articulos_propios/{nombre_unico}")
        articulo.foto = imagen_key

    db.commit()
    db.refresh(articulo)

    return {"message": "Artículo editado exitosamente"}



    
