# TFG

Este proyecto es un TRabajo de Fin de Grado de Ingeniería Informática sobre moda. 



# Comandos útiles y recurrentes
Frontend desde VisualStudio (en /frontend)
    > flutter clean
    > flutter pub get
    > flutter run

Backend desde terminal Ubuntu (en /backend)
    > uvicorn app.main:app --reload (para run en ubuntu WLS)
    > python -m uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload (para run en windows)

Mirar el estado de la BD (en /backend)
    > sudo service postgresql status
    > sudo service postgresql start

Actualizar algo de la BD (en /backend)
    > alembic revision --autogenerate -m "add foto field to ArticuloPropio"
    > alembic upgrade head

Conectarse a la BD (en /backend)
    > psql -U postgres -h localhost -d reverie_db

Ejecutar scripts (en /backend)
    > PYTHONPATH=$PWD python3 -m app.scripts.borrar_outfits_propios


DELETE FROM outfit_items WHERE outfit_id = 68;
DELETE FROM outfitpropio_articulo WHERE outfit_propio_id = 68;
DELETE FROM outfits_propios WHERE id = 68;


Tema de la hora
    > date
    > sudo ntpdate time.google.com