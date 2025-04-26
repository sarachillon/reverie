# backend/app/utils/auth.py

import jwt  # Usamos PyJWT para decodificar el JWT
from fastapi import Depends, HTTPException, Request
from sqlalchemy.orm import Session
from app.database.database import get_db
from app.models.models import Usuario
import logging
import os
from dotenv import load_dotenv

load_dotenv()

SECRET_KEY = os.getenv("SECRET_KEY")
ALGORITHM = "HS256"  

logger = logging.getLogger(__name__)

async def obtener_usuario_actual(request: Request, db: Session = Depends(get_db)) -> Usuario:
    auth_header = request.headers.get("Authorization")
    
    if not auth_header or not auth_header.startswith("Bearer "):
        raise HTTPException(status_code=401, detail="accessToken no está")
    
    token = auth_header.split(" ")[1]

    try:
        decoded_token = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        user_id = decoded_token.get("sub")

        if user_id is None:
            raise HTTPException(status_code=401, detail="Token no válido")
        user_id = int(user_id)

        usuario = db.query(Usuario).filter(Usuario.id == user_id).first()

        if not usuario:
            raise HTTPException(status_code=401, detail="Usuario no registrado")
    
    except jwt.ExpiredSignatureError:
        logger.error("Token expirado")
        raise HTTPException(status_code=401, detail="Token expirado")
    except jwt.JWTError as e:
        logger.error(f"Error decodificando el token: {e}")
        raise HTTPException(status_code=401, detail="Token inválido")

    return usuario
