from typing import Optional
from pydantic import BaseModel, EmailStr
from app.models.enummerations import GeneroPrefEnum
from fastapi import Form

class UserCreate(BaseModel):
    username: str
    email: EmailStr
    edad: int
    genero_pref: GeneroPrefEnum

    @classmethod
    def as_form(
        cls,
        username: str = Form(...),
        email: EmailStr = Form(...),
        edad: int = Form(...),
        genero_pref: GeneroPrefEnum = Form(...),
    ):
        return cls(
            username=username,
            email=email,
            edad=edad,
            genero_pref=genero_pref,
        )

class UserOut(BaseModel):
    id: int
    username: str
    email: str
    edad: int
    genero_pref: str
    foto_perfil: Optional[str] = None 

    class Config:
        from_attributes = True

class TokenUserResponse(BaseModel):
    access_token: str
    token_type: str
    user: UserOut
