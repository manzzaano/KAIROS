import logging
from datetime import datetime, timedelta

from jose import jwt
from passlib.context import CryptContext

from app.core.config import settings

logger = logging.getLogger(__name__)

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

ALGORITHM = "HS256"


def hash_password(password: str) -> str:
    try:
        return pwd_context.hash(password)
    except Exception as exc:
        logger.exception("hash_password failed: %s", exc)
        raise


def verify_password(plain: str, hashed: str) -> bool:
    try:
        return pwd_context.verify(plain, hashed)
    except Exception as exc:
        logger.exception("verify_password failed: %s", exc)
        return False


def create_access_token(user_id: int, expires_in_minutes: int = 30) -> str:
    try:
        expire = datetime.utcnow() + timedelta(minutes=expires_in_minutes)
        payload = {"sub": str(user_id), "exp": expire}
        return jwt.encode(payload, settings.jwt_secret, algorithm=ALGORITHM)
    except Exception as exc:
        logger.exception("create_access_token failed: %s", exc)
        raise
