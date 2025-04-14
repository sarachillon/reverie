from sqlalchemy import create_engine
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker

DATABASE_URL = "postgresql://postgres:Sara1212@localhost/reverie_db"


engine = create_engine(
    DATABASE_URL,
    pool_pre_ping=True,  # Verifica conexiones antes de usarlas
    pool_size=10,        # Número máximo de conexiones
    max_overflow=20,     # Conexiones adicionales permitidas
    pool_recycle=3600    # Recicla conexiones después de 1 hora
)

SessionLocal = sessionmaker(
    autocommit=False,
    autoflush=False,
    bind=engine,
    expire_on_commit=False  # Mejor para operaciones async
)

Base = declarative_base()

def get_db():
    """Generador de sesiones para inyección de dependencias"""
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

# Añade al final de database.py
def init_db():
    from app.models.models import Usuario  # Import aquí para evitar dependencias circulares
    Base.metadata.create_all(bind=engine)