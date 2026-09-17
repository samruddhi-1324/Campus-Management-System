from fastapi import APIRouter, Depends, Query, status
from sqlalchemy.ext.asyncio import AsyncSession

from app.api.deps import get_current_active_user, get_db, require_roles
from app.models.issue import IssueStatus, IssueUrgency
from app.models.user import User, UserRole
from app.schemas.issue import (
    IssueAssignmentUpdate,
    IssueCreate,
    IssueRead,
    IssueResolutionConfirm,
    IssueStatusUpdate,
    IssueUrgencyUpdate,
)
from app.services.issue_service import get_issue_service

router = APIRouter()


@router.post("/", response_model=IssueRead, status_code=status.HTTP_201_CREATED)
async def create_issue(
    issue_in: IssueCreate,
    current_user: User = Depends(get_current_active_user),
    db: AsyncSession = Depends(get_db),
):
    """Reporter submits new facilities issue with auto-generated reference number (FR-1.1, FR-1.2)."""
    service = get_issue_service(db)
    return await service.create_issue(issue_in, reporter=current_user)


@router.get("/my", response_model=list[IssueRead])
async def list_my_issues(
    status_filter: IssueStatus | None = Query(None),
    limit: int = Query(50, ge=1, le=100),
    offset: int = Query(0, ge=0),
    current_user: User = Depends(get_current_active_user),
    db: AsyncSession = Depends(get_db),
):
    """Reporter lists only their own reported issues (FR-1.3, NFR-SEC-01)."""
    service = get_issue_service(db)
    return await service.list_my_issues(
        reporter_id=current_user.id,
        status_filter=status_filter,
        limit=limit,
        offset=offset,
    )


@router.get("/queue", response_model=list[IssueRead])
async def list_coordinator_queue(
    status_filter: IssueStatus | None = Query(None),
    category_id: str | None = Query(None),
    urgency: IssueUrgency | None = Query(None),
    unassigned_only: bool = Query(False),
    limit: int = Query(100, ge=1, le=200),
    offset: int = Query(0, ge=0),
    current_user: User = Depends(
        require_roles(UserRole.COORDINATOR, UserRole.SUPERVISOR, UserRole.OPS_HEAD, UserRole.ADMIN)
    ),
    db: AsyncSession = Depends(get_db),
):
    """Staff triage queue for prioritizing, filtering, and dispatching issues (FR-1.9, FR-1.10)."""
    service = get_issue_service(db)
    return await service.list_coordinator_queue(
        status_filter=status_filter,
        category_id=category_id,
        urgency=urgency,
        unassigned_only=unassigned_only,
        limit=limit,
        offset=offset,
    )


@router.get("/{issue_id}", response_model=IssueRead)
async def get_issue_details(
    issue_id: str,
    current_user: User = Depends(get_current_active_user),
    db: AsyncSession = Depends(get_db),
):
    """Retrieve full details of an issue by ID."""
    service = get_issue_service(db)
    return await service.get_issue_by_id(issue_id)


@router.patch("/{issue_id}/status", response_model=IssueRead)
async def update_issue_status(
    issue_id: str,
    status_in: IssueStatusUpdate,
    current_user: User = Depends(
        require_roles(UserRole.COORDINATOR, UserRole.SUPERVISOR, UserRole.OPS_HEAD, UserRole.ADMIN)
    ),
    db: AsyncSession = Depends(get_db),
):
    """Coordinator/Supervisor updates issue status & adds notes with state machine validation (FR-1.13, FR-1.14)."""
    service = get_issue_service(db)
    return await service.update_issue_status(issue_id, status_in, actor=current_user)


@router.patch("/{issue_id}/assign", response_model=IssueRead)
async def assign_issue(
    issue_id: str,
    assign_in: IssueAssignmentUpdate,
    current_user: User = Depends(
        require_roles(UserRole.COORDINATOR, UserRole.SUPERVISOR, UserRole.OPS_HEAD, UserRole.ADMIN)
    ),
    db: AsyncSession = Depends(get_db),
):
    """Assign issue to a coordinator or maintenance team (FR-1.11, FR-1.12)."""
    service = get_issue_service(db)
    return await service.assign_issue(issue_id, assign_in, actor=current_user)


@router.patch("/{issue_id}/urgency", response_model=IssueRead)
async def update_issue_urgency(
    issue_id: str,
    urgency_in: IssueUrgencyUpdate,
    current_user: User = Depends(
        require_roles(UserRole.COORDINATOR, UserRole.SUPERVISOR, UserRole.OPS_HEAD, UserRole.ADMIN)
    ),
    db: AsyncSession = Depends(get_db),
):
    """Update issue urgency level (FR-1.10)."""
    service = get_issue_service(db)
    return await service.update_urgency(issue_id, urgency_in, actor=current_user)


@router.post("/{issue_id}/confirm", response_model=IssueRead)
async def confirm_resolution(
    issue_id: str,
    confirm_in: IssueResolutionConfirm,
    current_user: User = Depends(get_current_active_user),
    db: AsyncSession = Depends(get_db),
):
    """Reporter confirms resolution or reopens issue (FR-1.6, FR-1.7)."""
    service = get_issue_service(db)
    return await service.confirm_resolution(issue_id, confirm_in, reporter=current_user)
