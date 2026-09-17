from datetime import datetime

from app.models.user import ChannelType
from app.schemas.base import CoreModel


class DeviceRegistrationCreate(CoreModel):
    fcm_token: str | None = None
    transport_type: str = "fcm"  # fcm | websocket
    platform: str
    app_version: str
    device_model: str | None = None
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
    related_issue_id: str | None = None
    sent_at: datetime | None = None
