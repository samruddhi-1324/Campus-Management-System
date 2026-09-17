from fastapi import APIRouter, Body, Depends, status
from sqlalchemy.ext.asyncio import AsyncSession

from app.api.deps import get_current_active_user, get_db
from app.models.user import User
from app.schemas.auth import LoginRequest, TokenResponse
from app.schemas.user import UserCreate, UserRead
from app.services.auth_service import get_auth_service

router = APIRouter()


@router.post("/register", response_model=UserRead, status_code=status.HTTP_201_CREATED)
async def register(
    user_in: UserCreate,
    db: AsyncSession = Depends(get_db),
):
    """Register a new user account (Reporter by default)."""
    service = get_auth_service(db)
    return await service.register_user(user_in)


@router.post("/login", response_model=TokenResponse)
async def login(
    login_data: LoginRequest,
    db: AsyncSession = Depends(get_db),
):
    """Authenticate user and return JWT tokens with login alert dispatch (FR-NOTIF-08..10)."""
    service = get_auth_service(db)
    return await service.authenticate_user(login_data)


@router.post("/refresh", response_model=TokenResponse)
async def refresh_token(
    refresh_token_str: str = Body(..., embed=True),
    db: AsyncSession = Depends(get_db),
):
    """Exchange a valid refresh token for a new access & refresh token pair."""
    service = get_auth_service(db)
    return await service.refresh_access_token(refresh_token_str)


@router.get("/me", response_model=UserRead)
async def get_my_profile(
    current_user: User = Depends(get_current_active_user),
):
    """Return profile details of the authenticated user."""
    return current_user
