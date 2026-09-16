from typing import Optional
from datetime import datetime
from app.schemas.base import CoreModel
from app.models.user import ChannelType


class DeviceRegistrationCreate(CoreModel):
    fcm_token: Optional[str] = None
    transport_type: str = "fcm"  # fcm | websocket
    platform: str
    app_version: str
    device_model: Optional[str] = None
    locale: str = "en"
    timezone: str = "UTC"


class NotificationPreferenceUpdate(CoreModel):
    event_category: str
    channel_type: ChannelType
    enabled: bool


class NotificationLogRead(CoreModel):
    id: str
    channel: str
    template: str
    status: str
    related_issue_id: Optional[str] = None
    sent_at: Optional[datetime] = None
