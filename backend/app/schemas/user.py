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
    email: EmailStr

    model_config = {
        "from_attributes": True
    }
