# TFG


Para compilar:
Frontend desde VisualStudio: 
    > cd frontend
    > flutter run -d chrome
Backend desde terminal Ubuntu: 
    > cd backend
    > uvicorn app.main:app --reload
Compilar para ios
    ./update_info_plist.sh
    flutter build ios

Ruta para ver cosas: http://localhost:3000 
Ruta para iniciar sesion: http://localhost:8000/auth/google/login
Ruta de callback: http://localhost:8000/auth/google/callback 
