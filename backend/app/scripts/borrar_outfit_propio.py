from dotenv import load_dotenv
import os
from sqlalchemy.orm import sessionmaker
from sqlalchemy import create_engine, text
from app.models.models import OutfitPropio

# 1) Carga variables de entorno
load_dotenv()
DATABASE_URL = os.getenv("DATABASE_URL")

# 2) Conecta a la base de datos
engine = create_engine(DATABASE_URL)
Session = sessionmaker(bind=engine)
session = Session()

# 3) Elimina primero TODOS los outfit_items
session.execute(text("DELETE FROM outfit_items"))
# 4) Elimina luego todas las relaciones many-to-many
session.execute(text("DELETE FROM outfitpropio_articulo"))
# 5) Finalmente borra los outfits
session.execute(text("DELETE FROM outfits_propios"))

session.commit()
print("Todos los outfits y sus items han sido eliminados.")
