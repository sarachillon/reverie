from fastapi import APIRouter, HTTPException, Depends, Body
from fastapi.security import OAuth2PasswordBearer
import httpx
from typing import Annotated
from pydantic import BaseModel

router = APIRouter(
    prefix="/auth",  # Añade prefix aquí
    tags=["Google Auth"],  # Etiqueta más descriptiva
    responses={404: {"description": "No encontrado"}}  # Respuestas estándar
)

# Esquema para la respuesta
class GoogleTokenResponse(BaseModel):
    email: str
    name: str | None
    picture: str | None
    email_verified: bool

@router.post(
    "/google/verify",
    response_model=GoogleTokenResponse,  # Modelo de respuesta
    summary="Verificar token de Google",
    description="Valida un token ID de Google y devuelve información del usuario",
    responses={
        200: {"description": "Token verificado correctamente"},
        400: {"description": "Token inválido o error de verificación"}
    }
)
async def verify_google_token(
    token: Annotated[str, Body(..., embed=True, example="your_google_id_token")]
):
    """
    Verifica un token ID de Google recibido desde Flutter.
    
    Args:
    - token: Token ID de Google obtenido del cliente
    
    Returns:
    - Información básica del usuario verificada por Google
    """
    if not token:
        raise HTTPException(
            status_code=400,
            detail="Token no proporcionado",
            headers={"WWW-Authenticate": "Bearer"}
        )

    try:
        async with httpx.AsyncClient(timeout=10.0) as client:  # Timeout añadido
            response = await client.get(
                f"https://oauth2.googleapis.com/tokeninfo?id_token={token}"
            )
            
            if response.status_code != 200:
                raise HTTPException(
                    status_code=400,
                    detail="Token de Google inválido",
                    headers={"WWW-Authenticate": "Bearer"}
                )

            user_data = response.json()
            
            return {
                "email": user_data.get("email"),
                "name": user_data.get("name"),
                "picture": user_data.get("picture"),
                "email_verified": user_data.get("email_verified", False)
            }
            
    except httpx.RequestError as e:
        raise HTTPException(
            status_code=400,
            detail=f"Error al verificar el token: {str(e)}"
        )
    except Exception as e:
        raise HTTPException(
            status_code=500,
            detail=f"Error interno del servidor: {str(e)}"
        )