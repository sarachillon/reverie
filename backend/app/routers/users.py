from datetime import datetime, timedelta
from fastapi import APIRouter, HTTPException, Depends, Request
from fastapi.security import OAuth2PasswordBearer
from sqlalchemy.orm import Session
from app.schemas.user import UserCreate, UserOut, TokenUserResponse
from app.models.models import Usuario
from app.database.database import get_db 
import os
import jwt
from dotenv import load_dotenv
from fastapi import File, UploadFile, Form
from app.schemas.user import UserOut
from app.utils.auth import obtener_usuario_actual
from app.utils.s3 import subir_imagen_s3
import uuid
from app.models.enummerations import GeneroPrefEnum
from typing import Optional



load_dotenv()

SECRET_KEY = os.getenv("SECRET_KEY")
ALGORITHM = "HS256"
ACCESS_TOKEN_EXPIRE_MINUTES = 600
oauth2_scheme = OAuth2PasswordBearer(tokenUrl="token")

router = APIRouter(prefix="/auth", tags=["Users"])


def get_current_user_id(token: str = Depends(oauth2_scheme)) -> int:
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        return int(payload.get("sub"))
    except jwt.PyJWTError:
        raise HTTPException(status_code=401, detail="Token inválido o expirado")



@router.post("/login")
def login_user(email: str, db: Session = Depends(get_db)):
    user = db.query(Usuario).filter(Usuario.email == email).first()
    if not user:
        raise HTTPException(status_code=404, detail="Usuario no encontrado")

    payload = {
        "sub": str(user.id),
        "email": user.email,
        "exp": datetime.utcnow() + timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES),
    }
    access_token = jwt.encode(payload, SECRET_KEY, algorithm=ALGORITHM)

    return {
        "access_token": access_token,
        "token_type": "bearer",
        "user_id": user.id
    }


@router.post("/users", response_model=TokenUserResponse)
def create_user(user: UserCreate = Depends(UserCreate.as_form), db: Session = Depends(get_db)):
    print(f"Guardando en base de datos: {db.bind.url}") 
    existing_user = db.query(Usuario).filter(Usuario.email == user.email).first()
    if existing_user:
        raise HTTPException(status_code=400, detail="El email ya está registrado")

    db_user = Usuario(
        username=user.username,
        email=user.email,
        edad=user.edad,
        genero_pref=user.genero_pref,
    )
    db.add(db_user)
    db.commit()
    db.refresh(db_user)
    
    payload = {
        "sub": str(db_user.id),
        "email": db_user.email,
        "exp": datetime.utcnow() + timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES),
    }
    access_token = jwt.encode(payload, SECRET_KEY, algorithm=ALGORITHM)

    return TokenUserResponse(
        access_token=access_token,
        token_type="bearer",
        user=UserOut(
            id=db_user.id,
            username=db_user.username,
            email=db_user.email,
            edad=db_user.edad,
            genero_pref=db_user.genero_pref,
        )
    )



@router.get("/users")
def get_users(db: Session = Depends(get_db)):
    return db.query(Usuario).all()

@router.delete("/users/me")
async def eliminar_usuario_actual(request: Request, db: Session = Depends(get_db)):
    usuario_actual = await obtener_usuario_actual(request, db)
    if not usuario_actual:
        raise HTTPException(status_code=401, detail="Usuario no autenticado")

    try:
        db.delete(usuario_actual)
        db.commit()
        return {"message": "Cuenta eliminada correctamente"}
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=500, detail=f"Error al eliminar la cuenta: {str(e)}")



@router.get("/users/email/{email}", response_model=UserOut)
def get_user_by_email(email: str, db: Session = Depends(get_db)):
    user = db.query(Usuario).filter(Usuario.email == email).first()
    if not user:
        raise HTTPException(status_code=404, detail="Usuario no encontrado")
    return user

@router.post("/users/{id}/seguir")
def seguir_usuario(id: int, user_id: int = Depends(get_current_user_id), db: Session = Depends(get_db)):
    usuario_actual = db.query(Usuario).filter(Usuario.id == user_id).first()
    usuario_a_seguir = db.query(Usuario).filter(Usuario.id == id).first()

    if not usuario_a_seguir:
        raise HTTPException(status_code=404, detail="Usuario a seguir no encontrado")

    if usuario_a_seguir in usuario_actual.seguidos:
        raise HTTPException(status_code=400, detail="Ya estás siguiendo a este usuario")

    usuario_actual.seguidos.append(usuario_a_seguir)
    db.commit()
    return {"message": f"Ahora sigues a {usuario_a_seguir.username}"}


@router.post("/users/{id}/dejar_de_seguir")
def dejar_de_seguir_usuario(id: int, user_id: int = Depends(get_current_user_id), db: Session = Depends(get_db)):
    usuario_actual = db.query(Usuario).filter(Usuario.id == user_id).first()
    usuario_a_dejar = db.query(Usuario).filter(Usuario.id == id).first()

    if not usuario_a_dejar:
        raise HTTPException(status_code=404, detail="Usuario no encontrado")

    if usuario_a_dejar not in usuario_actual.seguidos:
        raise HTTPException(status_code=400, detail="No estás siguiendo a este usuario")

    usuario_actual.seguidos.remove(usuario_a_dejar)
    db.commit()
    return {"message": f"Has dejado de seguir a {usuario_a_dejar.username}"}

@router.get("/users/{id}/seguidos")
def obtener_seguidos(id: int, db: Session = Depends(get_db)):
    usuario = db.query(Usuario).filter(Usuario.id == id).first()
    if not usuario:
        raise HTTPException(status_code=404, detail="Usuario no encontrado")
    return [UserOut.from_orm(u) for u in usuario.seguidos]


@router.get("/users/{id}/seguidores")
def obtener_seguidores(id: int, db: Session = Depends(get_db)):
    usuario = db.query(Usuario).filter(Usuario.id == id).first()
    if not usuario:
        raise HTTPException(status_code=404, detail="Usuario no encontrado")
    return [UserOut.from_orm(u) for u in usuario.seguidores]


@router.get("/users/id/{id}", response_model=UserOut)
def get_user_by_id(id: int, db: Session = Depends(get_db)):
    user = db.query(Usuario).filter(Usuario.id == id).first()
    if not user:
        raise HTTPException(status_code=404, detail="Usuario no encontrado")
    return user


@router.get("/users/me", response_model=UserOut)
def get_current_user(user_id: int = Depends(get_current_user_id), db: Session = Depends(get_db)):
    user = db.query(Usuario).filter(Usuario.id == user_id).first()
    if not user:
        raise HTTPException(status_code=404, detail="Usuario no encontrado")
    return user



@router.post("/users/editar", response_model=UserOut)
async def editar_usuario(
    request: Request,
    username: str = Form(...),
    edad: int = Form(...),
    genero_pref: GeneroPrefEnum = Form(...),
    foto_perfil: Optional[UploadFile] = File(None),
    db: Session = Depends(get_db),
):
    from app.utils.auth import obtener_usuario_actual
    from app.utils.s3 import subir_imagen_s3_bytes, get_imagen_s3
    import uuid
    import base64

    usuario = await obtener_usuario_actual(request, db)
    if not usuario:
        raise HTTPException(status_code=401, detail="No autenticado")

    usuario.username = username
    usuario.edad = edad
    usuario.genero_pref = genero_pref

    if foto_perfil:
        original_bytes = await foto_perfil.read()
        nombre_base = foto_perfil.filename.rsplit('.', 1)[0]
        nombre_archivo = f"perfiles/{uuid.uuid4().hex}_{nombre_base}.png"
        imagen_key = await subir_imagen_s3_bytes(original_bytes, nombre_archivo)
        usuario.foto_perfil = imagen_key  # Guardamos solo la key en S3

    db.commit()
    db.refresh(usuario)

    if usuario.foto_perfil:
        try:
            imagen_bytes = await get_imagen_s3(usuario.foto_perfil)
            usuario.foto_perfil = base64.b64encode(imagen_bytes).decode("utf-8")
        except:
            usuario.foto_perfil = None

    return usuario
