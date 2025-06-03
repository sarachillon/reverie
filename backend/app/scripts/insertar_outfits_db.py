from sqlalchemy.orm import Session
from app.database.database import SessionLocal
from app.models.models import Usuario, ArticuloPropio, OutfitPropio
from app.models.enummerations import OcasionEnum, TemporadaEnum, ColorEnum
from datetime import datetime

def insertar_outfits_repetidos():
    db: Session = SessionLocal()
    try:
        collage_paths = [
            "articulos_propios/collage_6_1747060854.025261.png",
            "articulos_propios/collage_6_1747060889.221168.png",
            "articulos_propios/collage_6_1747117771.924935.png",
        ]

        usuarios = db.query(Usuario).all()
        if not usuarios:
            print("❌ No hay usuarios en la base de datos.")
            return

        for user in usuarios:
            articulos = db.query(ArticuloPropio).filter(ArticuloPropio.usuario_id == user.id).limit(3).all()
            if len(articulos) < 3:
                print(f"⚠️ Usuario {user.username} no tiene suficientes artículos. Se omite.")
                continue

            for i, collage in enumerate(collage_paths):
                outfit = OutfitPropio(
                    usuario_id=user.id,
                    titulo=f"Outfit repetido {i+1} de {user.username}",
                    descripcion_generacion="Outfit generado con collage repetido.",
                    fecha_creacion=datetime.utcnow(),
                    ocasiones=[OcasionEnum.CASUAL],
                    temporadas=[TemporadaEnum.VERANO],
                    colores=[ColorEnum.BLANCO, ColorEnum.AZUL],
                    collage_key=collage,
                    articulos_propios=articulos
                )
                db.add(outfit)

        db.commit()
        print("✔ Outfits insertados correctamente.")
    finally:
        db.close()


if __name__ == "__main__":
    insertar_outfits_repetidos()
