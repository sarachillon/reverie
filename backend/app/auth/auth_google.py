from fastapi import APIRouter, Request
from fastapi.responses import RedirectResponse
from starlette.config import Config
from starlette.responses import JSONResponse
import httpx
from urllib.parse import urlencode
from app.auth.oauth_config import GOOGLE_CLIENT_ID

router = APIRouter()

REDIRECT_URI = "http://localhost:8000/auth/google/callback"
FRONTEND_URL = "http://localhost:3000"

@router.get("/auth/google/login")
async def login_via_google():
    params = {
        "client_id": GOOGLE_CLIENT_ID,
        "response_type": "code",
        "scope": "openid email profile",
        "redirect_uri": REDIRECT_URI,
        "access_type": "offline",
        "prompt": "consent"
    }
    url = f"https://accounts.google.com/o/oauth2/v2/auth?{urlencode(params)}"
    return RedirectResponse(url)


@router.get("/auth/google/callback")
async def auth_callback(request: Request):
    code = request.query_params.get("code")
    if not code:
        return JSONResponse({"error": "No code provided"}, status_code=400)

    # Intercambiar code por token
    async with httpx.AsyncClient() as client:
        token_res = await client.post(
            "https://oauth2.googleapis.com/token",
            data={
                "code": code,
                "client_id": GOOGLE_CLIENT_ID,
                "redirect_uri": REDIRECT_URI,
                "grant_type": "authorization_code",
            },
            headers={"Content-Type": "application/x-www-form-urlencoded"},
        )
        token_data = token_res.json()

    access_token = token_data.get("access_token")
    if not access_token:
        return JSONResponse({"error": "No access token returned"}, status_code=400)

    # Obtener perfil del usuario
    async with httpx.AsyncClient() as client:
        user_info_res = await client.get(
            "https://www.googleapis.com/oauth2/v2/userinfo",
            headers={"Authorization": f"Bearer {access_token}"}
        )
        user_info = user_info_res.json()

    # Aquí puedes buscar/crear usuario y generar JWT, pero de momento hacemos redirect al frontend
    redirect_url = f"{FRONTEND_URL}/?token={access_token}"
    return RedirectResponse(redirect_url)
