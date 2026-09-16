from typing import Optional
from sqlalchemy.ext.asyncio import AsyncSession
from app.models.audit import AuditAction, AuditLogEntry


class AuditService:
    """Immutable audit logging service (NFR-AUDIT-01)."""

    def __init__(self, db: AsyncSession):
        self.db = db

    async def log_action(
        self,
        actor_id: str,
        action: AuditAction,
        target_entity: str,
        target_id: str,
        before_state: Optional[dict] = None,
        after_state: Optional[dict] = None,
        ip_address: Optional[str] = None,
        user_agent: Optional[str] = None,
    ) -> AuditLogEntry:
        pass


def get_audit_service(db: AsyncSession) -> AuditService:
    return AuditService(db)
