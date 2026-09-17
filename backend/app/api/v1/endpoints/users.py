
from fastapi import APIRouter, Depends, Query
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.api.deps import get_current_active_user, get_db, require_roles
from app.models.user import User, UserRole
from app.schemas.user import UserRead, UserUpdate

router = APIRouter()


@router.get("/me", response_model=UserRead)
async def get_my_profile(
    current_user: User = Depends(get_current_active_user),
):
    """Retrieve logged-in user profile."""
    return current_user


@router.patch("/me", response_model=UserRead)
async def update_my_profile(
    user_update: UserUpdate,
    current_user: User = Depends(get_current_active_user),
    db: AsyncSession = Depends(get_db),
):
    """Update profile attributes for current user."""
    if user_update.full_name is not None:
        current_user.full_name = user_update.full_name.strip()
    if user_update.department_id is not None:
        current_user.department_id = user_update.department_id

    await db.commit()
    await db.refresh(current_user)
    return current_user


@router.get("/coordinators", response_model=list[UserRead])
async def list_coordinators(
    department_id: str | None = Query(None),
    current_user: User = Depends(require_roles(UserRole.COORDINATOR, UserRole.SUPERVISOR, UserRole.OPS_HEAD, UserRole.ADMIN)),
    db: AsyncSession = Depends(get_db),
):
    """List coordinators and supervisors for issue triage and assignment."""
    stmt = select(User).where(
        User.role.in_([UserRole.COORDINATOR, UserRole.SUPERVISOR]),
        User.is_active,
    )
    if department_id:
        stmt = stmt.where(User.department_id == department_id)

    result = await db.execute(stmt)
    return list(result.scalars().all())
