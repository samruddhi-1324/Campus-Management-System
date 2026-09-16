from typing import List, Optional
from sqlalchemy.ext.asyncio import AsyncSession
from app.models.issue import Issue, IssueStatus, IssueUrgency
from app.schemas.issue import IssueCreate, IssueStatusUpdate, IssueAssignmentUpdate


class IssueService:
    """Core issue lifecycle service for Reporters, Coordinators, and Supervisors."""

    def __init__(self, db: AsyncSession):
        self.db = db

    async def create_issue(self, issue_in: IssueCreate, reporter_id: str) -> Issue:
        pass

    async def get_issue_by_id(self, issue_id: str) -> Optional[Issue]:
        pass

    async def get_reporter_issues(self, reporter_id: str) -> List[Issue]:
        pass

    async def update_status(self, issue_id: str, update_in: IssueStatusUpdate, actor_id: str) -> Issue:
        pass

    async def assign_coordinator(self, issue_id: str, assign_in: IssueAssignmentUpdate, actor_id: str) -> Issue:
        pass


def get_issue_service(db: AsyncSession) -> IssueService:
    return IssueService(db)
