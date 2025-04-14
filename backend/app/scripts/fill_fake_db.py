# backend/app/scripts/fill_fake_db.py

import sys
import os
from sqlalchemy.exc import IntegrityError

# Asegura que el path incluya la raíz del proyecto
sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), "..")))

from app.database.database import SessionLocal
from app.models.models import Usuario

def insertar_usuario_falso():
    db = SessionLocal()
    usuario = Usuario(
        username="ReverieTester",
        email="testing.reverie@gmail.com",
        edad="21",
        genero_pref="Ambos",
    )

    try:
        db.add(usuario)
        db.commit()
        print("Usuario falso insertado.")
    except IntegrityError:
        db.rollback()
        print("Usuario ya existe.")
    finally:
        db.close()

if __name__ == "__main__":
    insertar_usuario_falso()
