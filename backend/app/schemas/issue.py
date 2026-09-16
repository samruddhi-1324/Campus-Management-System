from typing import List, Optional
from datetime import datetime
from app.schemas.base import CoreModel
from app.models.issue import IssueStatus, IssueUrgency


class IssueCreate(CoreModel):
    title: str
    description: str
    category_id: Optional[str] = None
    building_id: Optional[str] = None
    room_id: Optional[str] = None
    location_details: Optional[str] = None
    urgency: IssueUrgency = IssueUrgency.MEDIUM
    attachment_ids: Optional[List[str]] = None


class IssueStatusUpdate(CoreModel):
    status: IssueStatus
    message: Optional[str] = None
    visibility: str = "external"  # external | internal
    reason: Optional[str] = None


class IssueAssignmentUpdate(CoreModel):
    coordinator_id: Optional[str] = None
    team_id: Optional[str] = None
    reason: Optional[str] = None


class IssueUrgencyUpdate(CoreModel):
    urgency: IssueUrgency
    reason: Optional[str] = None


class IssueResolutionConfirm(CoreModel):
    confirmed: bool  # True = Confirmed/Closed, False = Reopened
    feedback_notes: Optional[str] = None


class IssueRead(CoreModel):
    id: str
    reference_number: str
    title: str
    description: str
    category_id: Optional[str] = None
    building_id: Optional[str] = None
    room_id: Optional[str] = None
    location_details: Optional[str] = None
    status: IssueStatus
    urgency: IssueUrgency
    ai_suggested_urgency: Optional[str] = None
    ai_urgency_rationale: Optional[str] = None
    reporter_id: str
    assigned_coordinator_id: Optional[str] = None
    expected_resolution_at: Optional[datetime] = None
    created_at: datetime
    resolved_at: Optional[datetime] = None
    confirmed_at: Optional[datetime] = None
    closed_at: Optional[datetime] = None
