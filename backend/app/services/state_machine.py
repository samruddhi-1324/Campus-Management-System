from fastapi import HTTPException, status

from app.models.issue import IssueStatus
from app.models.user import UserRole


class IssueStateMachine:
    """Issue lifecycle state machine enforcing rules from SRS Section 5.6 & Appendix 16."""

    VALID_TRANSITIONS: dict[IssueStatus, set[IssueStatus]] = {
        IssueStatus.REPORTED: {IssueStatus.UNDERSTOOD, IssueStatus.ASSIGNED, IssueStatus.ESCALATED},
        IssueStatus.UNDERSTOOD: {IssueStatus.ASSIGNED, IssueStatus.WAITING_FOR_INFO, IssueStatus.ESCALATED},
        IssueStatus.ASSIGNED: {IssueStatus.INVESTIGATING, IssueStatus.WAITING_FOR_INFO, IssueStatus.ESCALATED},
        IssueStatus.INVESTIGATING: {IssueStatus.ACTION_TAKEN, IssueStatus.WAITING_FOR_INFO, IssueStatus.ESCALATED},
        IssueStatus.ACTION_TAKEN: {IssueStatus.RESOLVED, IssueStatus.INVESTIGATING, IssueStatus.ESCALATED},
        IssueStatus.WAITING_FOR_INFO: {IssueStatus.UNDERSTOOD, IssueStatus.ASSIGNED, IssueStatus.INVESTIGATING},
        IssueStatus.ESCALATED: {IssueStatus.ASSIGNED, IssueStatus.INVESTIGATING, IssueStatus.ACTION_TAKEN, IssueStatus.RESOLVED},
        IssueStatus.RESOLVED: {IssueStatus.CONFIRMED, IssueStatus.REOPENED, IssueStatus.CLOSED},
        IssueStatus.CONFIRMED: {IssueStatus.CLOSED},
        IssueStatus.REOPENED: {IssueStatus.INVESTIGATING, IssueStatus.ASSIGNED, IssueStatus.ESCALATED},
        IssueStatus.CLOSED: set(),  # Terminal state
    }

    @classmethod
    def can_transition(cls, from_state: IssueStatus, to_state: IssueStatus) -> bool:
        return to_state in cls.VALID_TRANSITIONS.get(from_state, set())

    @classmethod
    def validate_transition(cls, from_state: IssueStatus, to_state: IssueStatus, user_role: UserRole):
        """Validate state transition rules and role-based permissions (FR-1.28..30)."""
        if not cls.can_transition(from_state, to_state):
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail=f"Invalid transition from {from_state.value} to {to_state.value}",
            )

        # Reporter confirmation / reopening rule (FR-1.6, FR-1.7)
        if to_state in {IssueStatus.CONFIRMED, IssueStatus.REOPENED} and user_role != UserRole.REPORTER:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Only the reporter can confirm or reopen an issue",
            )
