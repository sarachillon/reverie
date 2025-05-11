
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
    temporada: Optional[TemporadaEnum] = None,
    ocasiones: List[OcasionEnum] = None,
    colores: Optional[List[ColorEnum]] = None
) -> Optional[OutfitPropio]:
    articulos = usuario.articulos_propios

    def cumple_filtros(articulo: ArticuloPropio):
        if temporada and temporada not in articulo.temporadas:
            return False
        if ocasiones and ocasiones not in articulo.ocasiones:
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
    collage_bytes = crear_collage_outfit(imagen_arriba, imagen_abajo)
    collage_key = await subir_imagen_s3_bytes(collage_bytes, f"collage_{usuario.id}_{datetime.utcnow().timestamp()}.png")

    outfit = OutfitPropio(
        usuario=usuario,
        titulo=titulo,
        descripcion_generacion=descripcion_generacion or "",
        fecha_creacion=datetime.now(),
        ocasiones=[ocasiones] if ocasiones else [],
        temporadas=[temporada] if temporada else [],
        colores=colores or [],
        articulos_propios=[arriba, abajo],
        collage_key=collage_key
    )

    return outfit


def crear_collage_outfit(imagen_arriba: bytes, imagen_abajo: bytes) -> bytes:
    img_arriba = Image.open(io.BytesIO(imagen_arriba)).convert("RGBA")
    img_abajo = Image.open(io.BytesIO(imagen_abajo)).convert("RGBA")

    ancho = max(img_arriba.width, img_abajo.width)
    alto = img_arriba.height + img_abajo.height // 2

    collage = Image.new("RGBA", (ancho, alto), (255, 255, 255, 0))
    collage.paste(img_abajo, ((ancho - img_abajo.width) // 2, alto - img_abajo.height))
    collage.paste(img_arriba, ((ancho - img_arriba.width) // 2, 0), mask=img_arriba)

    buffer = io.BytesIO()
    collage.save(buffer, format="PNG")
    return buffer.getvalue()