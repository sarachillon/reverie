from fastapi import APIRouter, HTTPException, Depends
from sqlalchemy.orm import Session
from app.schemas.user import UserCreate, UserOut
from app.models.models import Usuario
from app.database.database import get_db 

router = APIRouter(prefix="/auth", tags=["users"])

@router.post("/users", response_model=UserOut)
def create_user(user: UserCreate, db: Session = Depends(get_db)):
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