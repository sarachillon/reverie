# backend/app/models/models.py

from sqlalchemy import Column, Float, Integer, String, ForeignKey, Boolean, DateTime
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
    foto_perfil = Column(String, nullable=True)

    articulos_propios = relationship("ArticuloPropio", back_populates="usuario")
    outfits_propios = relationship("OutfitPropio", back_populates="usuario")
    seguidos = relationship("Usuario", secondary=seguidores, primaryjoin=id == seguidores.c.seguidor_id, secondaryjoin=id == seguidores.c.seguido_id, backref="seguidores")


class ArticuloPropio(Base):
    __tablename__ = "articulos_propios"

    id = Column(Integer, primary_key=True, index=True)
    usuario_id = Column(Integer, ForeignKey("usuarios.id"), nullable=False)
    nombre = Column(String, nullable=False)
    foto = Column(String, nullable=False)  # s3 key de la imagen del articulo
    categoria = Column(SqlEnum(CategoriaEnum), nullable=False)
    subcategoria = Column(String, nullable=False)
    ocasiones = Column(ARRAY(SqlEnum(OcasionEnum)), nullable=False)
    temporadas = Column(ARRAY(SqlEnum(TemporadaEnum)), nullable=False)
    colores = Column(ARRAY(SqlEnum(ColorEnum)), nullable=False)
    estilo = Column(SqlEnum(EstiloEnum), nullable=True)
    formalidad = Column(Integer, nullable=True)

    usuario = relationship("Usuario", back_populates="articulos_propios")
    outfits_propios = relationship("OutfitPropio", secondary=outfitpropio_articulo, back_populates="articulos_propios")


class OutfitPropio(Base):
    __tablename__ = "outfits_propios"

    id = Column(Integer, primary_key=True, index=True, autoincrement=True)
    usuario_id = Column(Integer, ForeignKey("usuarios.id"))
    titulo = Column(String, nullable=False)
    descripcion_generacion = Column(String)  
    fecha_creacion = Column(DateTime, nullable=False)
    ocasiones = Column(ARRAY(SqlEnum(OcasionEnum)), nullable=False)
    temporadas = Column(ARRAY(SqlEnum(TemporadaEnum)), nullable=True)
    colores = Column(ARRAY(SqlEnum(ColorEnum)), nullable=True)
    collage_key = Column(String, nullable=False)  # s3 key de la imagen del collage del outfit

    usuario = relationship("Usuario", back_populates="outfits_propios")
    articulos_propios = relationship("ArticuloPropio", secondary=outfitpropio_articulo, back_populates="outfits_propios")
    items = relationship("OutfitItem", back_populates="outfit", cascade="all, delete-orphan")
    colecciones = relationship("Coleccion", secondary=coleccion_outfit, back_populates="outfits")



class OutfitItem(Base):
    __tablename__ = "outfit_items"

    id = Column(Integer, primary_key=True, index=True)
    outfit_id = Column(Integer, ForeignKey("outfits_propios.id"), nullable=False)
    articulo_id = Column(Integer, ForeignKey("articulos_propios.id"), nullable=False)

    # Transformaciones en el lienzo
    x = Column(Float, nullable=False, default=0.0)
    y = Column(Float, nullable=False, default=0.0)
    scale = Column(Float, nullable=False, default=1.0)
    rotation = Column(Float, nullable=False, default=0.0)
    z_index = Column(Integer, nullable=False, default=0)

    articulo = relationship("ArticuloPropio")
    outfit = relationship("OutfitPropio", back_populates="items")



class Coleccion(Base):
    __tablename__ = "colecciones"

    id = Column(Integer, primary_key=True, index=True)
    nombre = Column(String, nullable=False)
    propietario_id = Column(Integer, ForeignKey("usuarios.id"), nullable=False)

    propietario = relationship("Usuario", backref="colecciones")
    outfits = relationship("OutfitPropio", secondary="coleccion_outfit", back_populates="colecciones")
