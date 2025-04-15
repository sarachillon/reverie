from database import engine, Base
from app.models import models
from app.database.database import init_db

print("Creando tablas en la base de datos...")
Base.metadata.create_all(bind=engine)
print("¡Tablas creadas con éxito!")
init_db()
print("Base de datos inicializada")