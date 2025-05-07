from dotenv import load_dotenv
import os
from sqlalchemy.orm import sessionmaker
from sqlalchemy import create_engine, text
from app.models.models import OutfitPropio, Outfit

# Cargar variables del .env
load_dotenv()

# Configurar la base de datos
DATABASE_URL = os.getenv("DATABASE_URL")
engine = create_engine(DATABASE_URL)
Session = sessionmaker(bind=engine)
session = Session()

# Eliminar relaciones de la tabla asociativa outfitpropio_articulo
session.execute(text("DELETE FROM outfitpropio_articulo"))

# Eliminar los outfits propios y luego los outfits base
session.query(OutfitPropio).delete()
session.query(Outfit).filter_by(tipo_outfit="propio").delete()

session.commit()
print("Outfits propios eliminados correctamente.")
