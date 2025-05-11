# backend/app/models/associations.py

from sqlalchemy import Table, Column, Integer, String, ForeignKey, Boolean
from app.database.database import Base
from sqlalchemy import Enum as SqlEnum
from app.models.enummerations import *

coleccion_articulo_propio = Table(
    "coleccion_articulo_propio", Base.metadata,
    Column("coleccion_id", Integer, ForeignKey("colecciones.id")),
    Column("articulo_propio_id", Integer, ForeignKey("articulos_propios.id"))
)

coleccion_outfit_propio = Table(
    "coleccion_outfit", Base.metadata,
    Column("coleccion_id", Integer, ForeignKey("colecciones.id")),
    Column("outfit_propio_id", Integer, ForeignKey("outfits_propios.id"))
)

outfitpropio_articulo = Table(
    "outfitpropio_articulo", Base.metadata,
    Column("outfit_propio_id", Integer, ForeignKey("outfits_propios.id")),
    Column("articulo_propio_id", Integer, ForeignKey("articulos_propios.id"))
)

