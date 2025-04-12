from fastapi import FastAPI
from auth.auth_google import router as auth_router

app = FastAPI()

app.include_router(auth_router, prefix="/auth", tags=["auth"])

