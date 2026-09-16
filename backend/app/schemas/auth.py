from typing import Optional
from pydantic import EmailStr
from app.schemas.base import CoreModel
from app.models.user import UserRole


class LoginRequest(CoreModel):
    email: EmailStr
    password: str
    device_info: Optional[dict] = None


class TokenResponse(CoreModel):
    access_token: str
    refresh_token: str
    token_type: str = "bearer"
    user_id: str
    role: UserRole
    full_name: str
