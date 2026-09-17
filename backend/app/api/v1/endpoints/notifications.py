from typing import List, Optional
from fastapi import APIRouter, Depends, Query, status
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.api.deps import get_current_active_user, get_db
from app.models.audit import NotificationLog
from app.models.user import User
from app.schemas.notification import DeviceRegistrationCreate, NotificationLogRead
from app.services.notification_service import get_notification_service

router = APIRouter()


@router.post("/devices", status_code=status.HTTP_200_OK)
async def register_device(
    device_in: DeviceRegistrationCreate,
    current_user: User = Depends(get_current_active_user),
    db: AsyncSession = Depends(get_db),
):
    """Register client FCM token or WebSocket device on login (FR-NOTIF-21..24, FR-NOTIF-31)."""
    service = get_notification_service(db)
    device = await service.register_device(user_id=current_user.id, device_in=device_in)
    return {"status": "success", "device_id": device.id}


@router.get("/inbox", response_model=List[NotificationLogRead])
async def get_notifications(
    limit: int = Query(50, ge=1, le=100),
    current_user: User = Depends(get_current_active_user),
    db: AsyncSession = Depends(get_db),
):
    """Retrieve in-app notifications history for logged-in user (FR-NOTIF-28)."""
    stmt = (
        select(NotificationLog)
        .where(NotificationLog.user_id == current_user.id)
        .order_by(NotificationLog.created_at.desc())
        .limit(limit)
    )
    result = await db.execute(stmt)
    return list(result.scalars().all())
