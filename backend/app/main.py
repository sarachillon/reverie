from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.routers.users import router as user_router  
from app.routers.articulo_propio import router as articulo_propio_router
from app.routers.outfit_propio import router as outfit_propio
from app.routers.imagen import router as imagen_router

app = FastAPI()

# Routers
app.include_router(user_router)
app.include_router(articulo_propio_router)
app.include_router(outfit_propio)
app.include_router(imagen_router)



# CORS (igual que antes)
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.get("/ping")
async def ping():
    return {"message": "pong"}