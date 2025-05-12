
from PIL import Image
import io
import base64
import random
from typing import List, Optional
from datetime import datetime
from app.models.models import ArticuloPropio, OutfitPropio, Usuario
from app.models.enummerations import TemporadaEnum, OcasionEnum, ColorEnum, SubcategoriaRopaEnum
from app.utils.s3 import get_imagen_s3, subir_imagen_s3_bytes

PARTES_ARRIBA = {
    SubcategoriaRopaEnum.CAMISAS,
    SubcategoriaRopaEnum.CAMISETAS,
    SubcategoriaRopaEnum.JERSEYS,
    SubcategoriaRopaEnum.MONOS,
    SubcategoriaRopaEnum.TRAJES,
}

PARTES_ABAJO = {
    SubcategoriaRopaEnum.PANTALONES,
    SubcategoriaRopaEnum.VAQUEROS,
    SubcategoriaRopaEnum.FALDAS_CORTAS,
    SubcategoriaRopaEnum.FALDAS_LARGAS,
    SubcategoriaRopaEnum.BERMUDAS,
}

CUERPO_ENTERO = {
    SubcategoriaRopaEnum.MONOS,
    SubcategoriaRopaEnum.VESTIDOS_CORTOS,
    SubcategoriaRopaEnum.VESTIDOS_LARGOS,
}

async def generar_outfit_propio(
    usuario: Usuario,
    titulo: str,
    descripcion_generacion: Optional[str] = None,
    temporadas: Optional[List[TemporadaEnum]] = None,
    ocasiones: List[OcasionEnum] = None,
    colores: Optional[List[ColorEnum]] = None
) -> Optional[OutfitPropio]:
    articulos = usuario.articulos_propios

    def cumple_filtros(articulo: ArticuloPropio):
        if temporadas and not any(t in articulo.temporadas for t in temporadas):
            return False
        if ocasiones and not any(o in articulo.ocasiones for o in ocasiones):
            return False
        if colores and not any(c in articulo.colores for c in colores):
            return False
        return True

    partes_arriba = [a for a in articulos if a.subcategoria in PARTES_ARRIBA and cumple_filtros(a)]
    partes_abajo = [a for a in articulos if a.subcategoria in PARTES_ABAJO and cumple_filtros(a)]

    if not partes_arriba or not partes_abajo:
        print("No se puede generar outfit")
        return None 
    
    combinaciones_validas = [
        (a, b)
        for a in partes_arriba
        for b in partes_abajo
        if (
            (len(a.colores) <= 1 or len(b.colores) <= 1)  # al menos uno con un solo color
            and not (len(a.colores) > 1 and len(b.colores) > 1)  # no ambos con múltiples colores
        )
    ]

    if not combinaciones_validas:
        print("No se puede generar outfit que cumpla con la restricción de colores")
        return None

    arriba, abajo = random.choice(combinaciones_validas)

    imagen_arriba = await get_imagen_s3(arriba.foto)
    imagen_abajo = await get_imagen_s3(abajo.foto)
    imagenes = [await get_imagen_s3(a.foto) for a in [arriba, abajo]]
    collage_bytes = crear_collage_outfit_v2(imagenes)
    collage_key = await subir_imagen_s3_bytes(collage_bytes, f"collage_{usuario.id}_{datetime.utcnow().timestamp()}.png")

    outfit = OutfitPropio(
        usuario=usuario,
        titulo=titulo,
        descripcion_generacion=descripcion_generacion or "",
        fecha_creacion=datetime.now(),
        ocasiones=ocasiones if ocasiones else [],
        temporadas=temporadas or [],
        colores=colores or [],
        articulos_propios=[arriba, abajo],
        collage_key=collage_key
    )

    return outfit


def crear_collage_outfit_v2(imagenes: List[bytes]) -> bytes:
    imagenes_pil = [Image.open(io.BytesIO(img)).convert("RGBA") for img in imagenes]

    # Redimensionamos: parte de abajo a max_width, parte de arriba a mismo ancho que la de abajo
    max_width = 300
    img_arriba, img_abajo = imagenes_pil

    # Redimensionar abajo a max_width
    ratio_abajo = max_width / img_abajo.width
    nuevo_abajo = img_abajo.resize(
        (int(img_abajo.width * ratio_abajo), int(img_abajo.height * ratio_abajo)),
        Image.Resampling.LANCZOS
    )

    # Redimensionar arriba con misma anchura que nuevo_abajo
    nuevo_ancho_arriba = int(nuevo_abajo.width * 0.60)
    ratio_arriba = nuevo_ancho_arriba / img_arriba.width
    nuevo_arriba = img_arriba.resize(
        (nuevo_ancho_arriba, int(img_arriba.height * ratio_arriba)),
        Image.Resampling.LANCZOS
    )

    resized_imgs = [nuevo_arriba, nuevo_abajo]


    spacing = 2

    if len(resized_imgs) == 1:
        img = resized_imgs[0]
        collage = Image.new("RGBA", (img.width + spacing * 2, img.height + spacing * 2), (255, 255, 255, 0))
        collage.paste(img, (spacing, spacing), img)

    elif len(resized_imgs) == 2:
        img1, img2 = resized_imgs

        # Solapamos unos 10 píxeles para evitar separación visual
        solape = 10
        collage_width = max(img1.width, img2.width)
        collage_height = img1.height + img2.height - solape
        collage = Image.new("RGBA", (collage_width, collage_height), (255, 255, 255, 0))

        x1 = (collage_width - img1.width) // 2
        x2 = (collage_width - img2.width) // 2
        y1 = 0
        y2 = img1.height - solape

        collage.paste(img1, (x1, y1), img1)
        collage.paste(img2, (x2, y2), img2)



    elif len(resized_imgs) == 3:
        img1, img2, img3 = resized_imgs
        column_height = img1.height + spacing + img2.height
        collage_width = img1.width + spacing + img3.width + spacing * 2
        collage_height = max(column_height, img3.height) + spacing * 2
        collage = Image.new("RGBA", (collage_width, collage_height), (255, 255, 255, 0))

        collage.paste(img1, (spacing, spacing), img1)
        collage.paste(img2, (spacing, img1.height + spacing * 2), img2)
        collage.paste(img3, (img1.width + spacing * 2, (collage_height - img3.height) // 2), img3)

    else:
        raise ValueError("Solo se soportan 1 a 3 imágenes en esta versión")

    buffer = io.BytesIO()
    collage.save(buffer, format="PNG")
    return buffer.getvalue()
