from pydantic import BaseModel
from typing import List, Optional
from app.schemas.articulo_propio import ArticuloPropioConImagen
from app.models.enummerations import OcasionEnum, TemporadaEnum, ColorEnum
from app.schemas.user import UserOut

# Este para /feed (incluye el usuario completo)
class OutfitPropioConUsuarioResponse(BaseModel):
    id: int
    titulo: str
    descripcion_generacion: Optional[str]
    ocasiones: List[OcasionEnum]
    temporadas: Optional[List[TemporadaEnum]]
    colores: Optional[List[ColorEnum]]
    articulos_propios: List[ArticuloPropioConImagen]
    collage_key: Optional[str]
    imagen: Optional[str]
    usuario: UserOut

    class Config:
        from_attributes = True


# Este para /stream (NO incluye usuario)
class OutfitPropioSimpleResponse(BaseModel):
    id: int
    titulo: str
    descripcion_generacion: Optional[str]
    ocasiones: List[OcasionEnum]
    temporadas: Optional[List[TemporadaEnum]]
    colores: Optional[List[ColorEnum]]
    articulos_propios: List[ArticuloPropioConImagen]
    collage_key: Optional[str]
    imagen: Optional[str]

    class Config:
        from_attributes = True

