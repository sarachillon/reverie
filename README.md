# TFG


Frontend desde VisualStudio (en /frontend)
    > cd frontend
    > flutter clean
    > flutter pub get
    > flutter run

Backend desde terminal Ubuntu (en /backend)
    > cd backend
    > uvicorn app.main:app --reload

Mirar el estado de la BD (en /backend)
    > sudo service postgresql status
    > sudo service postgresql start

Actualizar algo de la BD (en /backend)
    > alembic revision --autogenerate -m "add foto field to ArticuloPropio"
    > alembic upgrade head

Conectarse a la BD (en /backend)
    > psql -U postgres -h localhost -d reverie_db

Ejecutar scripts (en /backend)
    > PYTHONPATH=$PWD python3 -m app.scripts.borrar_articulos_propios