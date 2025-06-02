from pydantic import BaseModel
from typing import TYPE_CHECKING, List, Optional
from app.schemas.articulo_propio import ArticuloPropioConImagen
from app.models.enummerations import OcasionEnum, TemporadaEnum, ColorEnum
from app.schemas.user import UserOut


class OutfitItemResponse(BaseModel):
    id: int
    articulo_id: int
    outfit_id: int
    x: float
    y: float
    scale: float
    rotation: float
    z_index: int

    class Config:
        from_attributes = True
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
    items: List[OutfitItemResponse]  # para manual


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
    items: List[OutfitItemResponse] 


    class Config:
        from_attributes = True



OutfitPropioConUsuarioResponse.update_forward_refs()
OutfitPropioSimpleResponse.update_forward_refs()

