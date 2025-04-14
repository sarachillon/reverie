from fastapi import FastAPI
from app.auth.auth_google import router as auth_router
from fastapi.middleware.cors import CORSMiddleware

app = FastAPI()

app.include_router(auth_router, prefix="/auth", tags=["auth"])



app.add_middleware(
    CORSMiddleware,
    allow_origins=["http://localhost:3000"],  # Reemplaza con ["http://localhost:3000"] si sabes la URL exacta de tu frontend
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)
