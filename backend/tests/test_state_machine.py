import pytest
from fastapi import HTTPException

from app.models.issue import IssueStatus
from app.models.user import UserRole
from app.services.state_machine import IssueStateMachine


def test_valid_forward_transitions():
    assert IssueStateMachine.can_transition(IssueStatus.REPORTED, IssueStatus.UNDERSTOOD) is True
    assert IssueStateMachine.can_transition(IssueStatus.REPORTED, IssueStatus.ASSIGNED) is True
    assert IssueStateMachine.can_transition(IssueStatus.ASSIGNED, IssueStatus.INVESTIGATING) is True
    assert IssueStateMachine.can_transition(IssueStatus.INVESTIGATING, IssueStatus.ACTION_TAKEN) is True
    assert IssueStateMachine.can_transition(IssueStatus.ACTION_TAKEN, IssueStatus.RESOLVED) is True
    assert IssueStateMachine.can_transition(IssueStatus.RESOLVED, IssueStatus.CONFIRMED) is True
    assert IssueStateMachine.can_transition(IssueStatus.RESOLVED, IssueStatus.REOPENED) is True
    assert IssueStateMachine.can_transition(IssueStatus.CONFIRMED, IssueStatus.CLOSED) is True


def test_invalid_transitions():
    # Direct jump from reported to closed is invalid
    assert IssueStateMachine.can_transition(IssueStatus.REPORTED, IssueStatus.CLOSED) is False
    # Closed is a terminal state
    assert IssueStateMachine.can_transition(IssueStatus.CLOSED, IssueStatus.REPORTED) is False
    assert IssueStateMachine.can_transition(IssueStatus.CLOSED, IssueStatus.INVESTIGATING) is False


def test_validate_transition_role_enforcement():
    # Reporter can confirm or reopen a resolved issue
    IssueStateMachine.validate_transition(IssueStatus.RESOLVED, IssueStatus.CONFIRMED, UserRole.REPORTER)
    IssueStateMachine.validate_transition(IssueStatus.RESOLVED, IssueStatus.REOPENED, UserRole.REPORTER)

    # Coordinator cannot directly confirm/reopen (only reporter can)
    with pytest.raises(HTTPException) as exc_info:
        IssueStateMachine.validate_transition(IssueStatus.RESOLVED, IssueStatus.CONFIRMED, UserRole.COORDINATOR)
    assert exc_info.value.status_code == 403


def test_invalid_transition_raises_400():
    with pytest.raises(HTTPException) as exc_info:
        IssueStateMachine.validate_transition(IssueStatus.REPORTED, IssueStatus.CLOSED, UserRole.ADMIN)
    assert exc_info.value.status_code == 400
