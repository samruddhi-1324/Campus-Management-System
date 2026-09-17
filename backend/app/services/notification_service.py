import uuid
from datetime import UTC, datetime

from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.models.audit import NotificationLog
from app.models.user import UserDevice
from app.schemas.notification import (
    DeviceRegistrationCreate,
)


class NotificationService:
    """Notification management service coordinating multi-channel alerts (FR-NOTIF-01..34)."""

    def __init__(self, db: AsyncSession):
        self.db = db

    async def register_device(
        self,
        user_id: str,
        device_in: DeviceRegistrationCreate,
    ) -> UserDevice:
        """Register or update user client device for push notifications (FR-NOTIF-31)."""
        stmt = select(UserDevice).where(
            UserDevice.user_id == user_id,
            UserDevice.platform == device_in.platform,
        )
        result = await self.db.execute(stmt)
        device = result.scalar_one_or_none()

        if not device:
            device = UserDevice(
                id=str(uuid.uuid4()),
                user_id=user_id,
                fcm_token=device_in.fcm_token,
                transport_type=device_in.transport_type,
                platform=device_in.platform,
                app_version=device_in.app_version,
                device_model=device_in.device_model,
                locale=device_in.locale,
                timezone=device_in.timezone,
                is_active=True,
            )
            self.db.add(device)
        else:
            device.fcm_token = device_in.fcm_token
            device.app_version = device_in.app_version
            device.device_model = device_in.device_model
            device.last_seen_at = datetime.now(UTC)
            device.is_active = True

        await self.db.commit()
        await self.db.refresh(device)
        return device

    async def dispatch_notification(
        self,
        user_id: str,
        channel: str,
        template: str,
        related_issue_id: str | None = None,
        provider: str = "internal",
    ) -> NotificationLog:
        """Log outbound notification attempt with idempotency key (FR-NOTIF-04..05)."""
        idempotency_key = f"{user_id}_{template}_{related_issue_id or 'sys'}_{int(datetime.now(UTC).timestamp())}"

        log_entry = NotificationLog(
            id=str(uuid.uuid4()),
            user_id=user_id,
            channel=channel,
            template=template,
            provider=provider,
            status="delivered",
            related_issue_id=related_issue_id,
            idempotency_key=idempotency_key,
            sent_at=datetime.now(UTC),
        )
        self.db.add(log_entry)
        await self.db.commit()
        await self.db.refresh(log_entry)
        return log_entry

    async def send_login_alert(self, user_id: str, client_ip: str, user_agent: str):
        """Dispatch security login alert (FR-NOTIF-08..10)."""
        return await self.dispatch_notification(
            user_id=user_id,
            channel="email",
            template="security_login_alert",
            provider="smtp",
        )

    async def notify_issue_status_change(self, user_id: str, issue_id: str, new_status: str):
        """Notify reporter of issue status updates (FR-NOTIF-01)."""
        return await self.dispatch_notification(
            user_id=user_id,
            channel="in_app",
            template=f"issue_status_{new_status}",
            related_issue_id=issue_id,
            provider="internal",
        )


def get_notification_service(db: AsyncSession) -> NotificationService:
    return NotificationService(db)
