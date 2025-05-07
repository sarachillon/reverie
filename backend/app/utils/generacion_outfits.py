
import random
from typing import List, Optional
from datetime import datetime
from app.models.models import ArticuloPropio, OutfitPropio, Usuario
from app.models.enummerations import TemporadaEnum, OcasionEnum, ColorEnum, SubcategoriaRopaEnum

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

def generar_outfit_propietario(usuario: Usuario,
                                titulo: str,
                                descripcion: Optional[str] = None,
                                temporada: Optional[TemporadaEnum] = None,
                                ocasion: Optional[OcasionEnum] = None,
                                colores: Optional[List[ColorEnum]] = None) -> Optional[OutfitPropio]:
    articulos = usuario.articulos_propios

    def cumple_filtros(articulo: ArticuloPropio):
        if temporada and temporada not in articulo.temporadas:
            return False
        if ocasion and ocasion not in articulo.ocasiones:
            return False
        if colores and not any(c in articulo.colores for c in colores):
            return False
        return True

    partes_arriba = [a for a in articulos if a.subcategoria in PARTES_ARRIBA and cumple_filtros(a)]
    partes_abajo = [a for a in articulos if a.subcategoria in PARTES_ABAJO and cumple_filtros(a)]

    if not partes_arriba or not partes_abajo:
        return None  # No se puede generar outfit

    arriba = random.choice(partes_arriba)
    abajo = random.choice(partes_abajo)

    outfit = OutfitPropio(
        usuario=usuario,
        titulo=titulo,
        numero=1,  # Lógica futura si quieres múltiples por generación
        descripcion_generacion=descripcion or "",
        fecha_creacion=datetime.now(),
        ocasiones=[ocasion] if ocasion else [],    
        temporadas=[temporada] if temporada else [],
        colores=colores or [],    
        articulos_propios=[arriba, abajo]
    )

    return outfit
