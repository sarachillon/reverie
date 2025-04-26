from fastapi import APIRouter, UploadFile, File, HTTPException
from app.services.s3_service import upload_file_to_s3


router = APIRouter(prefix="/articulos", tags=["Artículos"])


@router.post("/upload-image")
async def upload_image(file: UploadFile = File(...)):
    try:
        key = upload_file_to_s3(file.file, file.filename)
        return {"message": "Imagen subida correctamente", "s3_key": key}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
