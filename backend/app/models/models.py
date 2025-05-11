# backend/app/models/models.py

from sqlalchemy import Column, Integer, String, ForeignKey, Boolean, DateTime
from sqlalchemy import Enum as SqlEnum, ARRAY
from sqlalchemy.orm import relationship, validates
from app.database.database import Base
from app.models.enummerations import *
from app.models.associations import *

class Usuario(Base):
    __tablename__ = "usuarios"

    id = Column(Integer, primary_key=True, index=True)
    username = Column(String, unique=True, nullable=False)
    email = Column(String, unique=True, nullable=False)
    edad = Column(String, nullable=False)
    genero_pref = Column(SqlEnum(GeneroPrefEnum), nullable=False)

    colecciones = relationship("Coleccion", back_populates="usuario")
    articulos_propios = relationship("ArticuloPropio", back_populates="usuario")
    interacciones = relationship("Interaccion", back_populates="usuario")
    outfits_propios = relationship("OutfitPropio", back_populates="usuario")

class Coleccion(Base):
    __tablename__ = "colecciones"

    id = Column(Integer, primary_key=True, index=True)
    usuario_id = Column(Integer, ForeignKey("usuarios.id"))
    nombre = Column(String, nullable=False)
    publica = Column(Boolean, default=False)
    colaborativa = Column(Boolean, default=False)

    usuario = relationship("Usuario", back_populates="colecciones")
    articulos_propios = relationship("ArticuloPropio", secondary=coleccion_articulo_propio, back_populates="colecciones")
    outfits_propios = relationship("OutfitPropio", secondary=coleccion_outfit_propio, back_populates="colecciones")

class ArticuloPropio(Base):
    __tablename__ = "articulos_propios"

    id = Column(Integer, primary_key=True, index=True)
    usuario_id = Column(Integer, ForeignKey("usuarios.id"), nullable=False)
    nombre = Column(String, nullable=False, unique=True)
    foto = Column(String, nullable=False)  # s3 key de la imagen del articulo
    categoria = Column(SqlEnum(CategoriaEnum), nullable=False)
    subcategoria = Column(String, nullable=False)
    ocasiones = Column(ARRAY(SqlEnum(OcasionEnum)), nullable=False)
    temporadas = Column(ARRAY(SqlEnum(TemporadaEnum)), nullable=False)
    colores = Column(ARRAY(SqlEnum(ColorEnum)), nullable=False)
    estilo = Column(SqlEnum(EstiloEnum), nullable=True)
    formalidad = Column(Integer, nullable=True)

    usuario = relationship("Usuario", back_populates="articulos_propios")
    colecciones = relationship("Coleccion", secondary=coleccion_articulo_propio, back_populates="articulos_propios")
    outfits_propios = relationship("OutfitPropio", secondary=outfitpropio_articulo, back_populates="articulos_propios")


class Interaccion(Base):
    __tablename__ = "interacciones"

    id = Column(Integer, primary_key=True, index=True)
    usuario_id = Column(Integer, ForeignKey("usuarios.id"))
    tipo = Column(SqlEnum(TipoInteraccionEnum), nullable=False)
    fecha = Column(String, nullable=False)
    busqueda = Column(String, nullable=True)

    usuario = relationship("Usuario", back_populates="interacciones")

class OutfitPropio(Base):
    __tablename__ = "outfits_propios"

    id = Column(Integer, primary_key=True, index=True)
    usuario_id = Column(Integer, ForeignKey("usuarios.id"))
    titulo = Column(String, nullable=False)
    descripcion_generacion = Column(String)  
    fecha_creacion = Column(DateTime, nullable=False)
    ocasiones = Column(ARRAY(SqlEnum(OcasionEnum)), nullable=False)
    temporadas = Column(ARRAY(SqlEnum(TemporadaEnum)), nullable=True)
    colores = Column(ARRAY(SqlEnum(ColorEnum)), nullable=True)
    collage_key = Column(String, nullable=False)  # s3 key de la imagen del collage del outfit

    usuario = relationship("Usuario", back_populates="outfits_propios")
    colecciones = relationship("Coleccion", secondary=coleccion_outfit_propio, back_populates="outfits_propios")
    articulos_propios = relationship("ArticuloPropio", secondary=outfitpropio_articulo, back_populates="outfits_propios")
