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
    outfits = relationship("Outfit", back_populates="usuario")

class Coleccion(Base):
    __tablename__ = "colecciones"

    id = Column(Integer, primary_key=True, index=True)
    usuario_id = Column(Integer, ForeignKey("usuarios.id"))
    nombre = Column(String, nullable=False)
    publica = Column(Boolean, default=False)
    colaborativa = Column(Boolean, default=False)

    usuario = relationship("Usuario", back_populates="colecciones")
    articulos_nuevos = relationship("ArticuloNuevo", secondary=coleccion_articulo_nuevo, back_populates="colecciones")
    articulos_propios = relationship("ArticuloPropio", secondary=coleccion_articulo_propio, back_populates="colecciones")
    outfits = relationship("Outfit", secondary=coleccion_outfit, back_populates="colecciones")

class ArticuloNuevo(Base):
    __tablename__ = "articulos_nuevos"

    url = Column(String, primary_key=True)

    colecciones = relationship("Coleccion", secondary=coleccion_articulo_nuevo, back_populates="articulos_nuevos")
    outfits_nuevos = relationship("OutfitNuevo", secondary=outfitnuevo_articulo, back_populates="articulos_nuevos")
    interacciones = relationship("Interaccion", back_populates="articulo_nuevo")

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

    usuario = relationship("Usuario", back_populates="articulos_propios")
    colecciones = relationship("Coleccion", secondary=coleccion_articulo_propio, back_populates="articulos_propios")
    outfits_propios = relationship("OutfitPropio", secondary=outfitpropio_articulo, back_populates="articulos_propios")


class Interaccion(Base):
    __tablename__ = "interacciones"

    id = Column(Integer, primary_key=True, index=True)
    usuario_id = Column(Integer, ForeignKey("usuarios.id"))
    articulo_url = Column(String, ForeignKey("articulos_nuevos.url"))
    tipo = Column(SqlEnum(TipoInteraccionEnum), nullable=False)
    fecha = Column(String, nullable=False)
    busqueda = Column(String, nullable=True)

    usuario = relationship("Usuario", back_populates="interacciones")
    articulo_nuevo = relationship("ArticuloNuevo", back_populates="interacciones")

class Outfit(Base):
    __tablename__ = "outfits"
    __mapper_args__ = {
        'polymorphic_identity': 'outfit',
        'polymorphic_on': 'tipo_outfit'
    }

    id = Column(Integer, primary_key=True, index=True)
    usuario_id = Column(Integer, ForeignKey("usuarios.id"))
    titulo = Column(String, nullable=False)
    numero = Column(Integer, nullable=False)
    tipo_outfit = Column(String(20))
    descripcion_generacion = Column(String)  
    fecha_creacion = Column(DateTime, nullable=False)
    ocasiones = Column(ARRAY(SqlEnum(OcasionEnum)), nullable=False)

    usuario = relationship("Usuario", back_populates="outfits")
    colecciones = relationship("Coleccion", secondary=coleccion_outfit, back_populates="outfits")

    @validates("tipo_outfit")
    def validate_tipo_outfit(self, key, value):
        if value not in ["nuevo", "propio"]:
            raise ValueError(f"Tipo de outfit '{value}' no válido.")
        return value

class OutfitPropio(Outfit):
    __tablename__ = "outfits_propios"
    __mapper_args__ = {'polymorphic_identity': 'propio'}

    id = Column(Integer, ForeignKey("outfits.id"), primary_key=True)
    articulos_propios = relationship("ArticuloPropio", secondary=outfitpropio_articulo, back_populates="outfits_propios")

class OutfitNuevo(Outfit):
    __tablename__ = "outfits_nuevos"
    __mapper_args__ = {'polymorphic_identity': 'nuevo'}

    id = Column(Integer, ForeignKey("outfits.id"), primary_key=True)
    rango_precio_min = Column(Integer)
    rango_precio_max = Column(Integer)
    tiendas = Column(String)
    articulos_nuevos = relationship("ArticuloNuevo", secondary=outfitnuevo_articulo, back_populates="outfits_nuevos")

