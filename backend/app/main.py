from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.auth.auth_google import router as auth_router
from app.auth.users import router as user_router  
from app.database.database import Base


app = FastAPI()

# Routers
app.include_router(auth_router, prefix="/auth", tags=["auth"])
app.include_router(user_router)  # Ya tiene su propio prefix

# CORS (igual que antes)
app.add_middleware(
    CORSMiddleware,
    allow_origins=["http://localhost:3000"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.get("/ping")
async def ping():
    return {"message": "pong"}