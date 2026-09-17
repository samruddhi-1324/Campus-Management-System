from datetime import datetime

from app.models.issue import IssueStatus, IssueUrgency
from app.schemas.base import CoreModel


class IssueCreate(CoreModel):
    title: str
    description: str
    category_id: str | None = None
    building_id: str | None = None
    room_id: str | None = None
    location_details: str | None = None
    urgency: IssueUrgency = IssueUrgency.MEDIUM
    attachment_ids: list[str] | None = None


class IssueStatusUpdate(CoreModel):
    status: IssueStatus
    message: str | None = None
    visibility: str = "external"  # external | internal
    reason: str | None = None


class IssueAssignmentUpdate(CoreModel):
    coordinator_id: str | None = None
    team_id: str | None = None
    reason: str | None = None


class IssueUrgencyUpdate(CoreModel):
    urgency: IssueUrgency
    reason: str | None = None


class IssueResolutionConfirm(CoreModel):
    confirmed: bool  # True = Confirmed/Closed, False = Reopened
    feedback_notes: str | None = None


class IssueRead(CoreModel):
    id: str
    reference_number: str
    title: str
    description: str
    category_id: str | None = None
    building_id: str | None = None
    room_id: str | None = None
    location_details: str | None = None
    status: IssueStatus
    urgency: IssueUrgency
    ai_suggested_urgency: str | None = None
    ai_urgency_rationale: str | None = None
    reporter_id: str
    assigned_coordinator_id: str | None = None
    expected_resolution_at: datetime | None = None
    created_at: datetime
    resolved_at: datetime | None = None
    confirmed_at: datetime | None = None
    closed_at: datetime | None = None
