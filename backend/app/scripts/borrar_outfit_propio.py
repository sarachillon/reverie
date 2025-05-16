from dotenv import load_dotenv
import os
from sqlalchemy.orm import sessionmaker
from sqlalchemy import create_engine, text
from app.models.models import OutfitPropio

# Cargar variables del .env
load_dotenv()

# Configurar la base de datos
DATABASE_URL = os.getenv("DATABASE_URL")
engine = create_engine(DATABASE_URL)
Session = sessionmaker(bind=engine)
session = Session()

# Eliminar relaciones en outfitpropio_articulo solo para outfits del 1 al 16
session.execute(text("""
    DELETE FROM outfitpropio_articulo 
    WHERE outfit_propio_id BETWEEN 1 AND 16
"""))

# Eliminar los outfits con ID entre 1 y 16
session.query(OutfitPropio).filter(OutfitPropio.id.between(1, 16)).delete(synchronize_session=False)

session.commit()
print("Outfits con ID del 1 al 16 eliminados correctamente.")
