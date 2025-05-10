from fastapi import APIRouter, UploadFile, File, HTTPException
from fastapi.responses import JSONResponse
from app.utils.remove_background import *
import base64

router = APIRouter(prefix="/imagen", tags=["Imagen"])

@router.post("/procesar")
async def procesar_imagen(foto: UploadFile = File(...)):
    try:
        original_bytes = await foto.read()
        imagen_procesada = quitar_fondo_imagen(original_bytes)
        imagen_base64 = base64.b64encode(imagen_procesada).decode("utf-8")
        return JSONResponse(content={"imagen_base64": imagen_base64})
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error al procesar imagen: {str(e)}")