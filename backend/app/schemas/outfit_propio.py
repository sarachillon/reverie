from pydantic import BaseModel
from typing import List, Optional
from app.schemas.articulo_propio import ArticuloPropioConImagen
from app.models.enummerations import OcasionEnum, TemporadaEnum, ColorEnum

class OutfitPropioResponse(BaseModel):
    id: int
    titulo: str
    descripcion: Optional[str]
    ocasion: OcasionEnum
    temporadas: Optional[List[TemporadaEnum]]
    colores: Optional[List[ColorEnum]]
    articulos_propios: List[ArticuloPropioConImagen]

    class Config:
        orm_mode = True
