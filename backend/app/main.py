from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
#from app.auth.auth_google import router as auth_router
from app.routers.users import router as user_router  
from app.routers.articulo_propio import router as articulo_propio_router
from app.routers.upload_image import router as upload_image_router

app = FastAPI()

# Routers
#app.include_router(auth_router, prefix="/auth", tags=["auth"])
app.include_router(user_router)
app.include_router(articulo_propio_router)
app.include_router(upload_image_router)



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