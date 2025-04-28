from sqlalchemy import create_engine, Column, String, Integer
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import Session
from sqlalchemy import update
import os
from dotenv import load_dotenv

load_dotenv()  

# Database connection details (use environment variables!)
DATABASE_URL = os.getenv("DATABASE_URL")
engine = create_engine(DATABASE_URL)
Base = declarative_base()

# Define your ArticuloPropio model (adjust to your actual model)
class ArticuloPropio(Base):
    __tablename__ = "articulos_propios"
    id = Column(Integer, primary_key=True)
    foto = Column(String)

def update_foto_keys():
    with Session(engine) as session:
        try:
            # Analyze URLs to handle different regions
            articulos_to_update = []
            for articulo in session.query(ArticuloPropio).all():
                if "reverie-photos.s3.eu-west-1.amazonaws.com" in articulo.foto:
                    articulo.foto = articulo.foto.replace("https://reverie-photos.s3.eu-west-1.amazonaws.com/", "", 1)
                    articulos_to_update.append(articulo)
                elif "reverie-photos.s3.eu-north-1.amazonaws.com" in articulo.foto:
                    articulo.foto = articulo.foto.replace("https://reverie-photos.s3.eu-north-1.amazonaws.com/", "", 1)
                    articulos_to_update.append(articulo)

            # Commit the changes in a single transaction
            session.commit()

            print(f"Updated {len(articulos_to_update)} records.")

        except Exception as e:
            session.rollback()  # Rollback in case of errors
            print(f"An error occurred: {e}")
        finally:
            session.close()

if __name__ == "__main__":
    update_foto_keys()