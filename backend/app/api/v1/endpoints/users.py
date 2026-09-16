from typing import List
from fastapi import APIRouter, Depends
from sqlalchemy.ext.asyncio import AsyncSession
from app.core.database import get_db
from app.schemas.user import UserRead, UserCreate
from app.api.deps import get_current_user_id

router = APIRouter()


@router.get("/me", response_model=UserRead)
async def get_my_profile(
    user_id: str = Depends(get_current_user_id),
    db: AsyncSession = Depends(get_db),
):
    """Retrieve logged-in user profile."""
    pass
