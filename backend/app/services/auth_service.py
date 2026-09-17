import uuid
from typing import Optional
from fastapi import HTTPException, status
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession
from jose import JWTError, jwt

from app.core.config import settings
from app.core.security import (
    ALGORITHM,
    verify_password,
    get_password_hash,
    create_access_token,
    create_refresh_token,
)
from app.models.user import User, UserRole
from app.schemas.auth import LoginRequest, TokenResponse
from app.schemas.user import UserCreate, UserRead


class AuthService:
    """Authentication and session management service (FR-1.25, FR-PLAT-10)."""

    def __init__(self, db: AsyncSession):
        self.db = db

    async def get_user_by_email(self, email: str) -> Optional[User]:
        stmt = select(User).where(User.email == email.lower().strip())
        result = await self.db.execute(stmt)
        return result.scalar_one_or_none()

    async def get_user_by_id(self, user_id: str) -> Optional[User]:
        stmt = select(User).where(User.id == user_id)
        result = await self.db.execute(stmt)
        return result.scalar_one_or_none()

    async def register_user(self, user_in: UserCreate) -> User:
        """Register a new user account."""
        existing_user = await self.get_user_by_email(user_in.email)
        if existing_user:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="A user with this email address already exists.",
            )

        hashed_pw = get_password_hash(user_in.password)
        new_user = User(
            id=str(uuid.uuid4()),
            email=user_in.email.lower().strip(),
            hashed_password=hashed_pw,
            full_name=user_in.full_name.strip(),
            role=user_in.role or UserRole.REPORTER,
            department_id=user_in.department_id,
            is_active=True,
        )
        self.db.add(new_user)
        await self.db.commit()
        await self.db.refresh(new_user)
        return new_user

    async def authenticate_user(self, login_data: LoginRequest) -> TokenResponse:
        """Authenticate user credentials and issue JWT access and refresh tokens."""
        user = await self.get_user_by_email(login_data.email)
        if not user or not verify_password(login_data.password, user.hashed_password):
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Invalid email or password credentials.",
                headers={"WWW-Authenticate": "Bearer"},
            )

        if not user.is_active:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="User account is deactivated. Please contact support.",
            )

        access_token = create_access_token(
            subject=user.id,
            role=user.role.value if hasattr(user.role, "value") else str(user.role),
            extra_claims={"email": user.email, "full_name": user.full_name},
        )
        refresh_token = create_refresh_token(subject=user.id)

        return TokenResponse(
            access_token=access_token,
            refresh_token=refresh_token,
            token_type="bearer",
            user_id=user.id,
            role=user.role,
            full_name=user.full_name,
        )

    async def refresh_access_token(self, refresh_token_str: str) -> TokenResponse:
        """Validate refresh token and issue a new access token pair."""
        try:
            payload = jwt.decode(
                refresh_token_str,
                settings.SECRET_KEY,
                algorithms=[ALGORITHM],
            )
            token_type: Optional[str] = payload.get("type")
            user_id: Optional[str] = payload.get("sub")
            if token_type != "refresh" or not user_id:
                raise HTTPException(
                    status_code=status.HTTP_401_UNAUTHORIZED,
                    detail="Invalid refresh token",
                )
        except JWTError:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Expired or invalid refresh token",
            )

        user = await self.get_user_by_id(user_id)
        if not user or not user.is_active:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="User no longer active or found",
            )

        access_token = create_access_token(
            subject=user.id,
            role=user.role.value if hasattr(user.role, "value") else str(user.role),
            extra_claims={"email": user.email, "full_name": user.full_name},
        )
        new_refresh = create_refresh_token(subject=user.id)

        return TokenResponse(
            access_token=access_token,
            refresh_token=new_refresh,
            token_type="bearer",
            user_id=user.id,
            role=user.role,
            full_name=user.full_name,
        )


def get_auth_service(db: AsyncSession) -> AuthService:
    return AuthService(db)
