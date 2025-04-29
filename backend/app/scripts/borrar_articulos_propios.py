from dotenv import load_dotenv
import os
from sqlalchemy.orm import sessionmaker
from sqlalchemy import create_engine
from app.models.models import ArticuloPropio

# Cargar variables del .env
load_dotenv()

# Configurar la base de datos
DATABASE_URL = os.getenv("DATABASE_URL")
engine = create_engine(DATABASE_URL)
Session = sessionmaker(bind=engine)
session = Session()

# Elimina todos los registros
session.query(ArticuloPropio).delete()
session.commit() 