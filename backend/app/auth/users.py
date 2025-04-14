from fastapi import APIRouter, HTTPException, Depends
from sqlalchemy.orm import Session
from app.schemas.user import UserCreate, UserOut
from app.models.models import Usuario
from app.database.database import get_db 

router = APIRouter(prefix="/auth", tags=["users"])

@router.post("/users", response_model=UserOut)
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
    return db_user


@router.get("/users")
def get_users(db: Session = Depends(get_db)):
    return db.query(Usuario).all()


@router.get("/users/{email}", response_model=UserOut)
def get_user_by_email(email: str, db: Session = Depends(get_db)):
    user = db.query(Usuario).filter(Usuario.email == email).first()
    if not user:
        raise HTTPException(status_code=404, detail="Usuario no encontrado")
    return user
