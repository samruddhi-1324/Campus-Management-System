from pydantic import EmailStr

from app.models.user import UserRole
from app.schemas.base import CoreModel


class LoginRequest(CoreModel):
    email: EmailStr
    password: str
    device_info: dict | None = None


class TokenResponse(CoreModel):
    access_token: str
    refresh_token: str
    token_type: str = "bearer"
    user_id: str
    role: UserRole
    full_name: str
