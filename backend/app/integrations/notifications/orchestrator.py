from typing import Any, Dict, List, Optional
from app.core.config import settings


class NotificationOrchestrator:
    """Central notification orchestrator fanning out domain events to enabled channels (FR-NOTIF-01a).

    Channels: In-app, Email (Gmail SMTP / Brevo / Resend failover), SMS, WhatsApp, Push (FCM + WebSocket).
    """

    async def dispatch_event(
        self,
        event_type: str,
        user_id: str,
        payload: Dict[str, Any],
        channels: Optional[List[str]] = None,
    ) -> Dict[str, Any]:
        """Orchestrate multi-channel dispatch with idempotency and background retry."""
        # Orchestration logic will be implemented in Phase 1
        return {
            "event_type": event_type,
            "user_id": user_id,
            "status": "queued",
            "channels": channels or ["in_app"],
        }


notification_orchestrator = NotificationOrchestrator()
