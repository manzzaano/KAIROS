import logging
import re

from fastapi import APIRouter, HTTPException, status

from app.schemas.user import (
    OAuthLogin,
    TokenResponse,
    UserLogin,
    UserRegister,
    UserResponse,
    USERNAME_PATTERN,
)
from app.services.auth_service import create_access_token, hash_password

logger = logging.getLogger(__name__)

router = APIRouter()

_DEMO_EMAIL = "demo@example.com"
_DEMO_USERNAME = "aspirant"
_DEMO_PASSWORD = "demo1234"
_DEMO_USER_ID = 1
_TAKEN_USERNAMES = {"admin", "root", "minos"}


def _validate_username(username: str) -> None:
    if not re.match(USERNAME_PATTERN, username):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Username debe ser 3-30 caracteres alfanuméricos o _",
        )
    if username.lower() in _TAKEN_USERNAMES:
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail="Username ya en uso",
        )


@router.post("/register", response_model=TokenResponse, status_code=status.HTTP_201_CREATED)
async def register(payload: UserRegister) -> TokenResponse:
    try:
        _validate_username(payload.username)
        _ = hash_password(payload.password)
        token = create_access_token(user_id=_DEMO_USER_ID)
        return TokenResponse(
            access_token=token,
            token_type="bearer",
            user=UserResponse(id=_DEMO_USER_ID, email=payload.email, username=payload.username),
        )
    except HTTPException:
        raise
    except Exception as exc:
        logger.exception("register failed: %s", exc)
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="No se pudo completar el registro",
        )


@router.post("/login", response_model=TokenResponse)
async def login(payload: UserLogin) -> TokenResponse:
    try:
        if payload.email != _DEMO_EMAIL or payload.password != _DEMO_PASSWORD:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Credenciales incorrectas",
            )
        token = create_access_token(user_id=_DEMO_USER_ID)
        return TokenResponse(
            access_token=token,
            token_type="bearer",
            user=UserResponse(id=_DEMO_USER_ID, email=_DEMO_EMAIL, username=_DEMO_USERNAME),
        )
    except HTTPException:
        raise
    except Exception as exc:
        logger.exception("login failed: %s", exc)
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="No se pudo iniciar sesión",
        )


@router.post("/google", response_model=TokenResponse)
async def login_google(payload: OAuthLogin) -> TokenResponse:
    try:
        token = create_access_token(user_id=_DEMO_USER_ID)
        return TokenResponse(
            access_token=token,
            token_type="bearer",
            user=UserResponse(
                id=_DEMO_USER_ID,
                email="google-user@example.com",
                username="google_aspirant",
            ),
        )
    except Exception as exc:
        logger.exception("google login failed: %s", exc)
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Google Sign-In falló",
        )


@router.post("/apple", response_model=TokenResponse)
async def login_apple(payload: OAuthLogin) -> TokenResponse:
    try:
        token = create_access_token(user_id=_DEMO_USER_ID)
        return TokenResponse(
            access_token=token,
            token_type="bearer",
            user=UserResponse(
                id=_DEMO_USER_ID,
                email="apple-user@example.com",
                username="apple_aspirant",
            ),
        )
    except Exception as exc:
        logger.exception("apple login failed: %s", exc)
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Apple Sign-In falló",
        )
