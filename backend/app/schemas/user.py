from pydantic import BaseModel, EmailStr
from app.models.enummerations import GeneroPrefEnum

class UserCreate(BaseModel):
    username: str
    email: EmailStr
    edad: int
    genero_pref: GeneroPrefEnum

class UserOut(BaseModel):
    id: int
    username: str
    email: str
    edad: int
    genero_pref: str

    class Config:
        orm_mode = True

class TokenUserResponse(BaseModel):
    access_token: str
    token_type: str
    user: UserOut
