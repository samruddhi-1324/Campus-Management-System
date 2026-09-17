import uuid
from datetime import UTC, datetime

from fastapi import HTTPException, status
from sqlalchemy import func, select
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.orm import selectinload

from app.models.audit import AuditAction
from app.models.issue import (
    Issue,
    IssueStateHistory,
    IssueStatus,
    IssueUpdate,
    IssueUrgency,
)
from app.models.user import User, UserRole
from app.schemas.issue import (
    IssueAssignmentUpdate,
    IssueCreate,
    IssueResolutionConfirm,
    IssueStatusUpdate,
    IssueUrgencyUpdate,
)
from app.services.audit_service import AuditService
from app.services.state_machine import IssueStateMachine


class IssueService:
    """Core Facilities Issue Lifecycle & State Machine Service (SRS §5 & §16)."""

    def __init__(self, db: AsyncSession):
        self.db = db
        self.audit_service = AuditService(db)

    async def _generate_reference_number(self) -> str:
        """Generate formatted unique reference number: CC-YYYY-XXXXX."""
        current_year = datetime.now(UTC).year
        prefix = f"CC-{current_year}-"

        # Query highest reference number for current year
        stmt = (
            select(func.count(Issue.id))
            .where(Issue.reference_number.like(f"{prefix}%"))
        )
        result = await self.db.execute(stmt)
        count = result.scalar() or 0
        sequence = count + 1
        return f"{prefix}{sequence:05d}"

    async def create_issue(self, issue_in: IssueCreate, reporter: User) -> Issue:
        """Reporter submits a new facilities issue (FR-1.1, FR-1.2)."""
        ref_number = await self._generate_reference_number()
        issue_id = str(uuid.uuid4())

        new_issue = Issue(
            id=issue_id,
            reference_number=ref_number,
            title=issue_in.title.strip(),
            description=issue_in.description.strip(),
            category_id=issue_in.category_id,
            building_id=issue_in.building_id,
            room_id=issue_in.room_id,
            location_details=issue_in.location_details.strip() if issue_in.location_details else None,
            status=IssueStatus.REPORTED,
            urgency=issue_in.urgency or IssueUrgency.MEDIUM,
            reporter_id=reporter.id,
        )
        self.db.add(new_issue)

        # Record initial state history
        history_entry = IssueStateHistory(
            id=str(uuid.uuid4()),
            issue_id=issue_id,
            from_state="NONE",
            to_state=IssueStatus.REPORTED.value,
            changed_by=reporter.id,
            reason="Initial issue reported by user.",
        )
        self.db.add(history_entry)

        # Audit log entry
        await self.audit_service.log_action(
            actor_id=reporter.id,
            action=AuditAction.CREATE,
            target_entity="issue",
            target_id=issue_id,
            after_state={"reference_number": ref_number, "status": IssueStatus.REPORTED.value, "title": new_issue.title},
        )

        await self.db.commit()
        await self.db.refresh(new_issue)
        return new_issue

    async def get_issue_by_id(self, issue_id: str) -> Issue:
        stmt = (
            select(Issue)
            .options(
                selectinload(Issue.attachments),
                selectinload(Issue.updates),
                selectinload(Issue.state_history),
            )
            .where(Issue.id == issue_id)
        )
        result = await self.db.execute(stmt)
        issue = result.scalar_one_or_none()
        if not issue:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail=f"Issue with ID {issue_id} not found",
            )
        return issue

    async def list_my_issues(
        self,
        reporter_id: str,
        status_filter: IssueStatus | None = None,
        limit: int = 50,
        offset: int = 0,
    ) -> list[Issue]:
        """Reporter lists only their own issues (FR-1.3, NFR-SEC-01)."""
        stmt = select(Issue).where(Issue.reporter_id == reporter_id)
        if status_filter:
            stmt = stmt.where(Issue.status == status_filter)
        stmt = stmt.order_by(Issue.created_at.desc()).offset(offset).limit(limit)
        result = await self.db.execute(stmt)
        return list(result.scalars().all())

    async def list_coordinator_queue(
        self,
        status_filter: IssueStatus | None = None,
        category_id: str | None = None,
        urgency: IssueUrgency | None = None,
        unassigned_only: bool = False,
        limit: int = 100,
        offset: int = 0,
    ) -> list[Issue]:
        """Coordinator prioritized triage queue (FR-1.9, FR-1.10)."""
        stmt = select(Issue)
        if status_filter:
            stmt = stmt.where(Issue.status == status_filter)
        if category_id:
            stmt = stmt.where(Issue.category_id == category_id)
        if urgency:
            stmt = stmt.where(Issue.urgency == urgency)
        if unassigned_only:
            stmt = stmt.where(Issue.assigned_coordinator_id.is_(None))

        # Order by status and creation date
        stmt = stmt.order_by(Issue.created_at.desc()).offset(offset).limit(limit)
        result = await self.db.execute(stmt)
        return list(result.scalars().all())

    async def update_issue_status(
        self,
        issue_id: str,
        status_in: IssueStatusUpdate,
        actor: User,
    ) -> Issue:
        """Validate state machine transition and record audit trail (FR-1.13..15, FR-1.29)."""
        issue = await self.get_issue_by_id(issue_id)
        old_status = issue.status
        new_status = status_in.status

        # Validate transition using IssueStateMachine
        IssueStateMachine.validate_transition(old_status, new_status, actor.role)

        issue.status = new_status
        now = datetime.now(UTC)

        # Handle specific state timestamp updates
        if new_status == IssueStatus.RESOLVED:
            issue.resolved_at = now
        elif new_status == IssueStatus.CONFIRMED:
            issue.confirmed_at = now
            issue.status = IssueStatus.CLOSED
            issue.closed_at = now
        elif new_status == IssueStatus.CLOSED:
            issue.closed_at = now

        # Add state history record
        history_entry = IssueStateHistory(
            id=str(uuid.uuid4()),
            issue_id=issue.id,
            from_state=old_status.value,
            to_state=new_status.value,
            changed_by=actor.id,
            reason=status_in.reason or status_in.message,
        )
        self.db.add(history_entry)

        # Add update note if message provided
        if status_in.message:
            update_note = IssueUpdate(
                id=str(uuid.uuid4()),
                issue_id=issue.id,
                author_id=actor.id,
                visibility=status_in.visibility or "external",
                message=status_in.message.strip(),
            )
            self.db.add(update_note)

        # Audit log entry
        await self.audit_service.log_action(
            actor_id=actor.id,
            action=AuditAction.STATUS_CHANGE,
            target_entity="issue",
            target_id=issue.id,
            before_state={"status": old_status.value},
            after_state={"status": new_status.value, "reason": status_in.reason},
        )

        await self.db.commit()
        await self.db.refresh(issue)
        return issue

    async def assign_issue(
        self,
        issue_id: str,
        assign_in: IssueAssignmentUpdate,
        actor: User,
    ) -> Issue:
        """Assign coordinator or maintenance team to issue (FR-1.11, FR-1.12)."""
        issue = await self.get_issue_by_id(issue_id)
        before_state = {
            "assigned_coordinator_id": issue.assigned_coordinator_id,
            "assigned_team_id": issue.assigned_team_id,
        }

        if assign_in.coordinator_id is not None:
            issue.assigned_coordinator_id = assign_in.coordinator_id
        if assign_in.team_id is not None:
            issue.assigned_team_id = assign_in.team_id

        # If reported and assigned, advance state to ASSIGNED
        if issue.status == IssueStatus.REPORTED and (issue.assigned_coordinator_id or issue.assigned_team_id):
            issue.status = IssueStatus.ASSIGNED
            history = IssueStateHistory(
                id=str(uuid.uuid4()),
                issue_id=issue.id,
                from_state=IssueStatus.REPORTED.value,
                to_state=IssueStatus.ASSIGNED.value,
                changed_by=actor.id,
                reason=assign_in.reason or "Assigned to staff",
            )
            self.db.add(history)

        await self.audit_service.log_action(
            actor_id=actor.id,
            action=AuditAction.ASSIGN,
            target_entity="issue",
            target_id=issue.id,
            before_state=before_state,
            after_state={
                "assigned_coordinator_id": issue.assigned_coordinator_id,
                "assigned_team_id": issue.assigned_team_id,
            },
        )

        await self.db.commit()
        await self.db.refresh(issue)
        return issue

    async def update_urgency(
        self,
        issue_id: str,
        urgency_in: IssueUrgencyUpdate,
        actor: User,
    ) -> Issue:
        """Coordinator/Supervisor overrides or updates urgency (FR-1.10)."""
        issue = await self.get_issue_by_id(issue_id)
        old_urgency = issue.urgency
        issue.urgency = urgency_in.urgency

        await self.audit_service.log_action(
            actor_id=actor.id,
            action=AuditAction.PRIORITY_CHANGE,
            target_entity="issue",
            target_id=issue.id,
            before_state={"urgency": old_urgency.value},
            after_state={"urgency": urgency_in.urgency.value, "reason": urgency_in.reason},
        )

        await self.db.commit()
        await self.db.refresh(issue)
        return issue

    async def confirm_resolution(
        self,
        issue_id: str,
        confirm_in: IssueResolutionConfirm,
        reporter: User,
    ) -> Issue:
        """Reporter confirms resolution or reopens issue (FR-1.6, FR-1.7)."""
        issue = await self.get_issue_by_id(issue_id)
        if issue.reporter_id != reporter.id and reporter.role != UserRole.ADMIN:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Only the original reporter can confirm or reopen this issue",
            )

        if issue.status != IssueStatus.RESOLVED:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail=f"Cannot confirm/reopen issue in status '{issue.status.value}'. Must be 'resolved'.",
            )

        now = datetime.now(UTC)
        if confirm_in.confirmed:
            old_status = issue.status
            issue.status = IssueStatus.CONFIRMED
            issue.confirmed_at = now
            issue.closed_at = now
            action = AuditAction.CLOSE
            reason = "Reporter confirmed resolution."
        else:
            old_status = issue.status
            issue.status = IssueStatus.REOPENED
            action = AuditAction.REOPEN
            reason = confirm_in.feedback_notes or "Reporter reopened issue."

        history = IssueStateHistory(
            id=str(uuid.uuid4()),
            issue_id=issue.id,
            from_state=old_status.value,
            to_state=issue.status.value,
            changed_by=reporter.id,
            reason=reason,
        )
        self.db.add(history)

        if confirm_in.feedback_notes:
            update = IssueUpdate(
                id=str(uuid.uuid4()),
                issue_id=issue.id,
                author_id=reporter.id,
                visibility="external",
                message=confirm_in.feedback_notes.strip(),
            )
            self.db.add(update)

        await self.audit_service.log_action(
            actor_id=reporter.id,
            action=action,
            target_entity="issue",
            target_id=issue.id,
            before_state={"status": old_status.value},
            after_state={"status": issue.status.value, "notes": confirm_in.feedback_notes},
        )

        await self.db.commit()
        await self.db.refresh(issue)
        return issue


def get_issue_service(db: AsyncSession) -> IssueService:
    return IssueService(db)
