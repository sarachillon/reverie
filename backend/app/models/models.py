from sqlalchemy import Column, Integer, String, ForeignKey, Boolean, Enum
from sqlalchemy.orm import relationship, validates
from database import Base
from enummerations import *


class Usuario(Base):
    __tablename__ = "usuarios"

    id = Column(Integer, primary_key=True, index=True)
    username = Column(String, unique=True, nullable=False)
    email = Column(String, unique=True, nullable=False)
    contraseña = Column(String, nullable=False)
    nombre = Column(String, nullable=False)
    apellido = Column(String, nullable=False)

    colecciones = relationship("Coleccion", back_populates="usuario")

class Coleccion(Base):
    __tablename__ = "colecciones"

    id = Column(Integer, primary_key=True, index=True)
    usuario_id = Column(Integer, ForeignKey("usuarios.id"))
    nombre = Column(String, nullable=False)
    publica = Column(Boolean, default=False)
    colaborativa = Column(Boolean, default=False)

    usuario = relationship("Usuario", back_populates="colecciones")


class Tienda(Base):
    __tablename__ = "tiendas"
    id = Column(Integer, primary_key=True, index=True)
    nombre = Column(String, unique=True, nullable=False)
    URL = Column(String)

    usuario = relationship("Articulo", back_populates="tiendas")


class ArticuloNuevo(Base):
    __tablename__ = "articulos_nuevos"

    url = Column(String, primary_key=True)
    
    colecciones = relationship("Coleccion", secondary="coleccion_articulo_nuevo", back_populates="articulos_nuevos")
    outfits_nuevos = relationship("OutfitNuevo", secondary="outfitnuevo_articulo", back_populates="articulos_nuevos")
    interacciones = relationship("Interaccion", back_populates="articulo_nuevo")


class ArticuloPropio(Base):
    __tablename__ = "articulos_propios"

    id = Column(Integer, primary_key=True, index=True)
    usuario_id = Column(Integer, ForeignKey("usuarios.id"), nullable=False)
    nombre = Column(String, nullable=False, unique=True)
    foto = Column(String, nullable=False)
    categoria = Column(Enum(CategoriaEnum), nullable=False)
    subcategoria = Column(String, nullable=False)
    temporada = Column(Enum(TemporadaEnum), nullable=False)
    tipo = Column(Enum(TipoInteraccionEnum), nullable=False)
    color = Column(Enum(ColorEnum), nullable=False)

    usuario = relationship("Usuario", back_populates="articulos_propios")
    colecciones = relationship("Coleccion", secondary="coleccion_articulo_propio", back_populates="articulos_propios")
    outfits_propios = relationship("OutfitPropio", secondary="outfitpropio_articulo", back_populates="articulos_propios")


    @validates("subcategoria", "categoria")
    def validate_subcategoria(self, key, value):
        setattr(self, key, value)
        cat = self.categoria
        subcat = self.subcategoria

        if cat == CategoriaEnum.ROPA and subcat not in [e.value for e in SubcategoriaRopaEnum]:
            raise ValueError(f"Subcategoría '{subcat}' no válida para la categoría Ropa.")
        elif cat == CategoriaEnum.CALZADO and subcat not in [e.value for e in SubcategoriaCalzadoEnum]:
            raise ValueError(f"Subcategoría '{subcat}' no válida para la categoría Calzado.")
        elif cat == CategoriaEnum.ACCESORIOS and subcat not in [e.value for e in SubcategoriaAccesoriosEnum]:
            raise ValueError(f"Subcategoría '{subcat}' no válida para la categoría Accesorios.")
        return value


class Interaccion(Base):
    __tablename__ = "interacciones"

    id = Column(Integer, primary_key=True, index=True)
    usuario_id = Column(Integer, ForeignKey("usuarios.id"))
    articulo_url = Column(String, ForeignKey("articulos_nuevos.url"))
    tipo = Column(Enum(TipoInteraccionEnum), nullable=False)
    fecha = Column(String, nullable=False)
    busqueda = Column(String, nullable=True)

    usuario = relationship("Usuario", back_populates="interacciones")
    articulo_nuevo = relationship("ArticuloNuevo", back_populates="interacciones")


class Outfit(Base):
    __tablename__ = "outfits"

    id = Column(Integer, primary_key=True, index=True)
    generacion_id = Column(Integer, ForeignKey("generaciones_outfit.id"))
    usuario_id = Column(Integer, ForeignKey("usuarios.id"))
    titulo = Column(String, nullable=False)
    numero = Column(Integer, nullable=False)

    generacion = relationship("GeneracionOutfit", back_populates="outfits")
    usuario = relationship("Usuario", back_populates="outfits")
    colecciones = relationship("Coleccion", secondary="coleccion_outfit", back_populates="outfits")
    outfit_propio = relationship("OutfitPropio", uselist=False, back_populates="outfit")
    outfit_nuevo = relationship("OutfitNuevo", uselist=False, back_populates="outfit")


class GeneracionOutfit(Base):
    __tablename__ = "generaciones_outfit"

    id = Column(Integer, primary_key=True, index=True)
    descripcion = Column(String, nullable=False)
    color = Column(Enum(ColorEnum), nullable=False)

    outfits = relationship("Outfit", back_populates="generacion")


class OutfitPropio(Base):
    __tablename__ = "outfits_propios"

    id = Column(Integer, ForeignKey("outfits.id"), primary_key=True)

    outfit = relationship("Outfit", back_populates="outfit_propio")
    articulos_propios = relationship("ArticuloPropio", secondary="outfitpropio_articulo", back_populates="outfits_propios")


class OutfitNuevo(Base):
    __tablename__ = "outfits_nuevos"

    id = Column(Integer, ForeignKey("outfits.id"), primary_key=True)
    rango_precio_min = Column(Integer)
    rango_precio_max = Column(Integer)
    tiendas = Column(String)

    outfit = relationship("Outfit", back_populates="outfit_nuevo")
    articulos_nuevos = relationship("ArticuloNuevo", secondary="outfitnuevo_articulo", back_populates="outfits_nuevos")
