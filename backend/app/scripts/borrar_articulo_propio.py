from dotenv import load_dotenv
import os
from sqlalchemy import create_engine, text

load_dotenv()

DATABASE_URL = os.getenv("DATABASE_URL")
engine = create_engine(DATABASE_URL)

articulo_id = 53

with engine.begin() as conn:
    # 1. Eliminar referencias desde outfitpropio_articulo
    conn.execute(text("DELETE FROM outfitpropio_articulo WHERE articulo_propio_id = :id"), {"id": articulo_id})
    
    # 2. Eliminar el artículo
    conn.execute(text("DELETE FROM articulos_propios WHERE id = :id"), {"id": articulo_id})

print("Artículo y sus referencias eliminados.")
