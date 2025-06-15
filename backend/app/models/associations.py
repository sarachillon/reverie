# backend/app/models/associations.py

from sqlalchemy import Table, Column, Integer, String, ForeignKey, Boolean
from app.database.database import Base
from sqlalchemy import Enum as SqlEnum
from app.models.enummerations import *


outfitpropio_articulo = Table(
    "outfitpropio_articulo", Base.metadata,
    Column("outfit_propio_id", Integer, ForeignKey("outfits_propios.id")),
    Column("articulo_propio_id", Integer, ForeignKey("articulos_propios.id"))
)

seguidores = Table(
    "seguidores", Base.metadata,
    Column("seguido_id", Integer, ForeignKey("usuarios.id"), primary_key=True),
    Column("seguidor_id", Integer, ForeignKey("usuarios.id"), primary_key=True)
)

coleccion_outfit = Table(
    "coleccion_outfit", Base.metadata,
    Column("coleccion_id", Integer, ForeignKey("colecciones.id")),
    Column("outfit_id", Integer, ForeignKey("outfits_propios.id"))
)
