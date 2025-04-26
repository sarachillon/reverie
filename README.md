# TFG


Frontend desde VisualStudio (en /frontend)
    > cd frontend
    > flutter clean
    > flutter pub get
    > flutter run

Backend desde terminal Ubuntu (en /backend)
    > cd backend
    > uvicorn app.main:app --reload

Base de datos (en /backend)
    > sudo service postgresql status
    > sudo service postgresql start
    > alembic revision --autogenerate -m "add foto field to ArticuloPropio"
    > alembic upgrade head
