from typing import Optional
from sqlalchemy.ext.asyncio import AsyncSession
from app.core.security import verify_password, get_password_hash, create_access_token, create_refresh_token
from app.schemas.auth import LoginRequest, TokenResponse


class AuthService:
    """Authentication and session management service (FR-1.25, FR-PLAT-10)."""

    def __init__(self, db: AsyncSession):
        self.db = db

    async def authenticate_user(self, login_data: LoginRequest) -> Optional[TokenResponse]:
        # Implementation in development phase
        pass


def get_auth_service(db: AsyncSession) -> AuthService:
    return AuthService(db)
