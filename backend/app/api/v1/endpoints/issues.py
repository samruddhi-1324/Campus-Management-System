from typing import List, Optional
from fastapi import APIRouter, Depends, Query
from sqlalchemy.ext.asyncio import AsyncSession
from app.core.database import get_db
from app.api.deps import get_current_user_id
from app.schemas.issue import (
    IssueCreate,
    IssueRead,
    IssueStatusUpdate,
    IssueAssignmentUpdate,
    IssueUrgencyUpdate,
    IssueResolutionConfirm,
)

router = APIRouter()


@router.post("/", response_model=IssueRead)
async def create_issue(
    issue_in: IssueCreate,
    user_id: str = Depends(get_current_user_id),
    db: AsyncSession = Depends(get_db),
):
    """Reporter submits new issue with reference number generation (FR-1.1, FR-1.2)."""
    pass


@router.get("/my", response_model=List[IssueRead])
async def list_my_issues(
    user_id: str = Depends(get_current_user_id),
    db: AsyncSession = Depends(get_db),
):
    """Reporter lists only their own issues (FR-1.3, NFR-SEC-01)."""
    pass


@router.get("/coordinator/queue", response_model=List[IssueRead])
async def list_coordinator_queue(
    user_id: str = Depends(get_current_user_id),
    db: AsyncSession = Depends(get_db),
):
    """Coordinator views prioritized queue (FR-1.9, FR-1.10)."""
    pass


@router.patch("/{issue_id}/status", response_model=IssueRead)
async def update_issue_status(
    issue_id: str,
    status_in: IssueStatusUpdate,
    user_id: str = Depends(get_current_user_id),
    db: AsyncSession = Depends(get_db),
):
    """Coordinator/Supervisor updates issue status & adds notes (FR-1.13, FR-1.14)."""
    pass


@router.post("/{issue_id}/confirm", response_model=IssueRead)
async def confirm_resolution(
    issue_id: str,
    confirm_in: IssueResolutionConfirm,
    user_id: str = Depends(get_current_user_id),
    db: AsyncSession = Depends(get_db),
):
    """Reporter confirms resolution or reopens issue (FR-1.6, FR-1.7)."""
    pass
