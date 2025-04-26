from sqlalchemy.orm import sessionmaker
from sqlalchemy import create_engine
from app.models.models import Usuario
import os
from dotenv import load_dotenv

load_dotenv()


# Configura la base de datos
DATABASE_URL = os.getenv("DATABASE_URL")  
engine = create_engine(DATABASE_URL)
Session = sessionmaker(bind=engine)
session = Session()

# Realiza la consulta
usuarios = session.query(Usuario).all()

# Muestra los usuarios
for usuario in usuarios:
    print(usuario.id, usuario.username, usuario.email, usuario.edad, usuario.genero_pref)

# Cierra la sesión
session.close()
