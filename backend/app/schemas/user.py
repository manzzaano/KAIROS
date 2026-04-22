from pydantic import BaseModel, EmailStr, Field


USERNAME_PATTERN = r"^[A-Za-z0-9_]{3,30}$"


class UserRegister(BaseModel):
    email: EmailStr
    username: str = Field(..., min_length=3, max_length=30, pattern=USERNAME_PATTERN)
    password: str = Field(..., min_length=8)


class UserLogin(BaseModel):
    email: EmailStr
    password: str = Field(..., min_length=8)


class OAuthLogin(BaseModel):
    id_token: str = Field(..., min_length=1)


class UserResponse(BaseModel):
    id: int
    email: EmailStr
    username: str


class TokenResponse(BaseModel):
    access_token: str
    token_type: str = "bearer"
    user: UserResponse
