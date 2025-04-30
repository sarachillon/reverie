from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.routers.users import router as user_router  
from app.routers.articulo_propio import router as articulo_propio_router

app = FastAPI()

# Routers
app.include_router(user_router)
app.include_router(articulo_propio_router)



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