from sqlalchemy.orm import Session
from app.database.database import Base, engine
from app.database.database import SessionLocal
from app.models.models import Usuario, ArticuloPropio, OutfitPropio
from app.models.associations import seguidores
from app.models.enummerations import (
    CategoriaEnum, SubcategoriaRopaEnum, SubcategoriaCalzadoEnum, SubcategoriaAccesoriosEnum,
    OcasionEnum, TemporadaEnum, ColorEnum, EstiloEnum, GeneroPrefEnum
)
from datetime import datetime

def populate_data():
    db: Session = SessionLocal()
    try:
        usuarios = [
            Usuario(username="marta", email="marta@example.com", edad="25", genero_pref=GeneroPrefEnum.MUJER),
            Usuario(username="alex", email="alex@example.com", edad="28", genero_pref=GeneroPrefEnum.AMBOS),
            Usuario(username="noa", email="noa@example.com", edad="22", genero_pref=GeneroPrefEnum.MUJER),
            Usuario(username="lucas", email="lucas@example.com", edad="26", genero_pref=GeneroPrefEnum.HOMBRE),
            Usuario(username="emma", email="emma@example.com", edad="24", genero_pref=GeneroPrefEnum.AMBOS),
        ]
        db.add_all(usuarios)
        db.commit()
        for user in usuarios:
            db.refresh(user)

        articulos_data = [
            ("Top negro", CategoriaEnum.ROPA, SubcategoriaRopaEnum.CAMISETAS,
             [OcasionEnum.CASUAL, OcasionEnum.CENA, OcasionEnum.TRABAJO_INFORMAL],
             [TemporadaEnum.VERANO, TemporadaEnum.ENTRETIEMPO],
             [ColorEnum.NEGRO], EstiloEnum.PUNK, 2, "articulos_propios/sin_fondo_1746987784837.png"),

            ("Falda cuadros", CategoriaEnum.ROPA, SubcategoriaRopaEnum.FALDAS_CORTAS,
             [OcasionEnum.CASUAL], [TemporadaEnum.VERANO],
             [ColorEnum.NEGRO, ColorEnum.BLANCO], EstiloEnum.PUNK, 2, "articulos_propios/sin_fondo_1746987821877.png"),

            ("Gafas de sol negras", CategoriaEnum.ACCESORIOS, SubcategoriaAccesoriosEnum.GAFAS,
             [OcasionEnum.CASUAL, OcasionEnum.CENA, OcasionEnum.EVENTO, OcasionEnum.FORMAL, OcasionEnum.TRABAJO_FORMAL, OcasionEnum.TRABAJO_INFORMAL],
             [TemporadaEnum.VERANO, TemporadaEnum.ENTRETIEMPO],
             [ColorEnum.NEGRO], EstiloEnum.MINIMAL, 6, "articulos_propios/sin_fondo_1746987859036.png"),

            ("Vestido flores azul", CategoriaEnum.ROPA, SubcategoriaRopaEnum.VESTIDOS_CORTOS,
             [OcasionEnum.CASUAL, OcasionEnum.CENA], [TemporadaEnum.VERANO],
             [ColorEnum.AZUL], EstiloEnum.ELEGANT, 8, "articulos_propios/sin_fondo_1746988088097.png"),

            ("Bermudas vaqueras", CategoriaEnum.ROPA, SubcategoriaRopaEnum.BERMUDAS,
             [OcasionEnum.CASUAL, OcasionEnum.TRABAJO_INFORMAL],
             [TemporadaEnum.VERANO, TemporadaEnum.ENTRETIEMPO],
             [ColorEnum.AZUL], EstiloEnum.PUNK, 2, "articulos_propios/sin_fondo_1746989309890.png"),

            ("Vaqueros mom", CategoriaEnum.ROPA, SubcategoriaRopaEnum.VAQUEROS,
             [OcasionEnum.CASUAL, OcasionEnum.TRABAJO_INFORMAL],
             [TemporadaEnum.ENTRETIEMPO, TemporadaEnum.INVIERNO],
             [ColorEnum.AZUL], EstiloEnum.PUNK, 2, "articulos_propios/sin_fondo_1746989350187.png"),

            ("Bolso zadig", CategoriaEnum.ACCESORIOS, SubcategoriaAccesoriosEnum.MOCHILAS,
             [OcasionEnum.CASUAL, OcasionEnum.CENA, OcasionEnum.EVENTO, OcasionEnum.FORMAL, OcasionEnum.TRABAJO_FORMAL, OcasionEnum.TRABAJO_INFORMAL],
             [TemporadaEnum.VERANO, TemporadaEnum.ENTRETIEMPO, TemporadaEnum.INVIERNO],
             [ColorEnum.NEGRO], EstiloEnum.ELEGANT, 8, "articulos_propios/sin_fondo_1746989397086.png"),
        ]

        for user in usuarios:
            articulos_usuario = []
            for i, data in enumerate(articulos_data):
                nombre, categoria, subcategoria, ocasiones, temporadas, colores, estilo, formalidad, foto = data
                articulo = ArticuloPropio(
                    usuario_id=user.id,
                    nombre=f"{nombre} de {user.username}",
                    foto=foto,
                    categoria=categoria,
                    subcategoria=subcategoria.value,
                    ocasiones=ocasiones,
                    temporadas=temporadas,
                    colores=colores,
                    estilo=estilo,
                    formalidad=formalidad
                )
                db.add(articulo)
                db.commit()
                db.refresh(articulo)
                articulos_usuario.append(articulo)

            for j in range(3):
                outfit = OutfitPropio(
                    usuario_id=user.id,
                    titulo=f"Outfit {j+1} de {user.username}",
                    descripcion_generacion="Outfit de prueba generado manualmente.",
                    fecha_creacion=datetime.utcnow(),
                    ocasiones=[OcasionEnum.CASUAL],
                    temporadas=[TemporadaEnum.VERANO],
                    colores=[ColorEnum.BLANCO, ColorEnum.AZUL],
                    collage_key=f"s3/outfits/{user.username}_outfit{j+1}.png",
                    articulos_propios=articulos_usuario[j: j+3]
                )
                db.add(outfit)
                db.commit()

        relaciones = [
            (usuarios[0], usuarios[1]),
            (usuarios[0], usuarios[2]),
            (usuarios[1], usuarios[3]),
            (usuarios[2], usuarios[0]),
            (usuarios[3], usuarios[4]),
            (usuarios[4], usuarios[0]),
        ]

        for seguidor, seguido in relaciones:
            db.execute(seguidores.insert().values(seguidor_id=seguidor.id, seguido_id=seguido.id))
        db.commit()

        print("\n✔ Datos poblados correctamente.")
    finally:
        db.close()


def reset_database():
    Base.metadata.drop_all(bind=engine)
    Base.metadata.create_all(bind=engine)



if __name__ == "__main__":
    reset_database()
    populate_data()
