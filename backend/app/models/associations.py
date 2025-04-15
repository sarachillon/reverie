from sqlalchemy import Table, Column, Integer, String, ForeignKey, Boolean
from app.database.database import Base

coleccion_articulo_propio = Table(
    "coleccion_articulo_propio", Base.metadata,
    Column("coleccion_id", Integer, ForeignKey("colecciones.id")),
    Column("articulo_propio_id", Integer, ForeignKey("articulos_propios.id"))
)

coleccion_articulo_nuevo = Table(
    "coleccion_articulo_nuevo", Base.metadata,
    Column("coleccion_id", Integer, ForeignKey("colecciones.id")),
    Column("articulo_nuevo_url", String, ForeignKey("articulos_nuevos.url"))
)

coleccion_outfit = Table(
    "coleccion_outfit", Base.metadata,
    Column("coleccion_id", Integer, ForeignKey("colecciones.id")),
    Column("outfit_id", Integer, ForeignKey("outfits.id"))
)

outfitpropio_articulo = Table(
    "outfitpropio_articulo", Base.metadata,
    Column("outfit_id", Integer, ForeignKey("outfits_propios.id")),
    Column("articulo_propio_id", Integer, ForeignKey("articulos_propios.id"))
)

outfitnuevo_articulo = Table(
    "outfitnuevo_articulo", Base.metadata,
    Column("outfit_id", Integer, ForeignKey("outfits_nuevos.id")),
    Column("articulo_nuevo_url", String, ForeignKey("articulos_nuevos.url"))
)
