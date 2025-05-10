from dotenv import load_dotenv
import os
from sqlalchemy.orm import sessionmaker
from sqlalchemy import create_engine, text
from app.models.models import ArticuloPropio, OutfitPropio

# Cargar variables del .env
load_dotenv()
DATABASE_URL = os.getenv("DATABASE_URL")
engine = create_engine(DATABASE_URL)
Session = sessionmaker(bind=engine)
session = Session()

# 1. Borrar relaciones en tabla intermedia
session.execute(text("DELETE FROM outfitpropio_articulo"))

# 2. Borrar outfits
session.query(OutfitPropio).delete()

# 3. Borrar artículos
session.query(ArticuloPropio).delete()

session.commit()
