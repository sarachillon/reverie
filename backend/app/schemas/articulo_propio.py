# backend/app/schemas/articulo_propio.py

from pydantic import BaseModel
from pydantic_settings import BaseSettings
from typing import List, Optional
from app.models.enummerations import *
from app.schemas.user import UserOut


class ArticuloCreate(BaseModel):
    id: int
    nombre: str
    categoria: CategoriaEnum
    subcategoria_ropa: Optional[SubcategoriaRopaEnum] = None
    subcategoria_calzado: Optional[SubcategoriaCalzadoEnum] = None
    subcategoria_accesorios: Optional[SubcategoriaAccesoriosEnum] = None
    ocasiones: List[OcasionEnum] = []
    temporadas: List[TemporadaEnum] = []
    colores: List[ColorEnum] = []
    foto: str  # URL de la imagen en S3


class ArticuloPropioConImagen(BaseModel):
    id: int
    usuario_id: int
    nombre: str
    categoria: CategoriaEnum
    subcategoria: Optional[str] = None
    ocasiones: List[OcasionEnum] = []
    temporadas: List[TemporadaEnum] = []
    colores: List[ColorEnum] = []
    foto: str # URL de la imagen en S3
    urlFirmada: Optional[str] = None 
    usuario: UserOut


    class Config:
        #orm_mode = True  #  Para trabajar con objetos SQLAlchemy
        from_attributes = True


class ArticuloPropioConUrl(BaseModel):
    id: int
    usuario_id: int
    nombre: str
    categoria: CategoriaEnum
    subcategoria: Optional[str] = None
    ocasiones: List[OcasionEnum] = []
    temporadas: List[TemporadaEnum] = []
    colores: List[ColorEnum] = []
    foto: str # URL de la imagen en S3
    urlFirmada: Optional[str] = None
    usuario: UserOut

    class Config:
        from_attributes = True
