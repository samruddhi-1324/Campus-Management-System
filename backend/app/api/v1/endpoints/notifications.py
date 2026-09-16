from typing import List
from fastapi import APIRouter, Depends
from sqlalchemy.ext.asyncio import AsyncSession
from app.core.database import get_db
from app.api.deps import get_current_user_id
from app.schemas.notification import DeviceRegistrationCreate, NotificationPreferenceUpdate, NotificationLogRead

router = APIRouter()


@router.post("/devices")
async def register_device(
    device_in: DeviceRegistrationCreate,
    user_id: str = Depends(get_current_user_id),
    db: AsyncSession = Depends(get_db),
):
    """Register client FCM token or WebSocket device on login (FR-NOTIF-21..24, FR-NOTIF-31)."""
    pass


@router.get("/inbox", response_model=List[NotificationLogRead])
async def get_notifications(
    user_id: str = Depends(get_current_user_id),
    db: AsyncSession = Depends(get_db),
):
    """Retrieve in-app notifications history (FR-NOTIF-28)."""
    pass
