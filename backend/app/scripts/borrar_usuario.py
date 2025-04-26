from dotenv import load_dotenv
import os
from sqlalchemy.orm import sessionmaker
from sqlalchemy import create_engine
from app.models.models import Usuario

# Cargar variables del .env
load_dotenv()

# Configurar la base de datos
DATABASE_URL = os.getenv("DATABASE_URL")
engine = create_engine(DATABASE_URL)
Session = sessionmaker(bind=engine)
session = Session()


user_id_to_delete = 10
usuario = session.query(Usuario).filter(Usuario.id == user_id_to_delete).first()

if usuario:
    print(f"Borrando usuario: {usuario.username} ({usuario.email})")
    session.delete(usuario)
    session.commit()
    print("Usuario eliminado.")
else:
    print("Usuario no encontrado.")

# Cerrar sesión
session.close()
