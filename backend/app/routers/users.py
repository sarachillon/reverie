from datetime import datetime, timedelta
from fastapi import APIRouter, HTTPException, Depends
from sqlalchemy.orm import Session
import jwt
from app.schemas.user import UserCreate, UserOut, TokenUserResponse
from app.models.models import Usuario
from app.database.database import get_db 
import os
from dotenv import load_dotenv

load_dotenv()

SECRET_KEY = os.getenv("SECRET_KEY")
ALGORITHM = "HS256"
ACCESS_TOKEN_EXPIRE_MINUTES = 60

router = APIRouter(prefix="/auth", tags=["users"])

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
def create_user(user: UserCreate, db: Session = Depends(get_db)):
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


@router.get("/users/{email}", response_model=UserOut)
def get_user_by_email(email: str, db: Session = Depends(get_db)):
    user = db.query(Usuario).filter(Usuario.email == email).first()
    if not user:
        raise HTTPException(status_code=404, detail="Usuario no encontrado")
    return user
