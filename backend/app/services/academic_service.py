import uuid
from datetime import UTC, datetime

from fastapi import HTTPException, status
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.models.academic import AcademicConcern, AcademicConcernType, ConfidentialAccessLog
from app.models.audit import AuditAction, AuditLogEntry
from app.models.issue import Issue, IssueStatus, IssueUrgency
from app.schemas.academic import AcademicConcernCreate


class AcademicService:
    """Confidential Academic Concern routing and resolution service (FR-2.1..2.3, NFR-SEC-01)."""

    def __init__(self, db: AsyncSession):
        self.db = db

    async def create_academic_concern(
        self, concern_in: AcademicConcernCreate, reporter_id: str
    ) -> AcademicConcern:
        """Reporter submits confidential academic grievance (FR-2.1, FR-2.2)."""
        # 1. Create underlying issue for tracking reference number & state machine
        issue_id = str(uuid.uuid4())
        ref_num = f"ACAD-{datetime.now(UTC).strftime('%Y%m%d')}-{uuid.uuid4().hex[:6].upper()}"

        issue = Issue(
            id=issue_id,
            reference_number=ref_num,
            title=concern_in.title,
            description=concern_in.description,
            status=IssueStatus.REPORTED,
            urgency=IssueUrgency.MEDIUM,
            reporter_id=reporter_id,
        )
        self.db.add(issue)

        # 2. Create confidential academic concern record
        concern_id = str(uuid.uuid4())
        concern = AcademicConcern(
            id=concern_id,
            issue_id=issue_id,
            concern_type=concern_in.concern_type,
            course_code=concern_in.course_code,
            academic_term=concern_in.academic_term,
            is_confidential=True,
        )
        self.db.add(concern)

        # 3. Log audit entry
        audit_entry = AuditLogEntry(
            id=str(uuid.uuid4()),
            actor_id=reporter_id,
            action=AuditAction.CREATE,
            target_entity="academic_concern",
            target_id=concern_id,
            after_state={
                "title": concern_in.title,
                "concern_type": concern_in.concern_type.value,
                "is_confidential": True,
            },
        )
        self.db.add(audit_entry)

        await self.db.commit()
        await self.db.refresh(concern)
        return concern

    async def get_academic_concern(
        self, concern_id: str, officer_id: str, access_reason: str = "Triage Review"
    ) -> AcademicConcern:
        """Fetch academic concern with mandatory confidential access logging (FR-2.2, NFR-AUDIT-01)."""
        stmt = select(AcademicConcern).where(AcademicConcern.id == concern_id)
        result = await self.db.execute(stmt)
        concern = result.scalar_one_or_none()

        if not concern:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail=f"Academic concern {concern_id} not found",
            )

        # Mandatory confidential access log entry (FR-2.2)
        access_log = ConfidentialAccessLog(
            id=str(uuid.uuid4()),
            academic_concern_id=concern_id,
            accessed_by=officer_id,
            access_reason=access_reason,
            accessed_at=datetime.now(UTC),
        )
        self.db.add(access_log)
        await self.db.commit()

        return concern

    async def list_academic_queue(
        self, officer_id: str, concern_type: AcademicConcernType | None = None
    ) -> list[AcademicConcern]:
        """Designated Academic Affairs officer views academic queue (FR-2.2, FR-2.3)."""
        stmt = select(AcademicConcern)
        if concern_type:
            stmt = stmt.where(AcademicConcern.concern_type == concern_type)

        stmt = stmt.order_by(AcademicConcern.created_at.desc())
        result = await self.db.execute(stmt)
        return list(result.scalars().all())


def get_academic_service(db: AsyncSession) -> AcademicService:
    return AcademicService(db)
