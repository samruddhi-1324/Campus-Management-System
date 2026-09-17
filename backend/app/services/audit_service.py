import uuid

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
        before_state: dict | None = None,
        after_state: dict | None = None,
        ip_address: str | None = None,
        user_agent: str | None = None,
    ) -> AuditLogEntry:
        """Create and persist an immutable audit trail entry."""
        entry = AuditLogEntry(
            id=str(uuid.uuid4()),
            actor_id=actor_id,
            action=action,
            target_entity=target_entity,
            target_id=target_id,
            before_state=before_state,
            after_state=after_state,
            ip_address=ip_address,
            user_agent=user_agent,
        )
        self.db.add(entry)
        # Note: commit is handled by caller or session transaction
        return entry


def get_audit_service(db: AsyncSession) -> AuditService:
    return AuditService(db)
