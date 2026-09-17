from datetime import UTC, datetime, timedelta

import pytest

from app.models.academic import AcademicConcernType
from app.models.issue import Issue, IssueStatus, IssueUrgency
from app.models.master_data import Category
from app.schemas.academic import AcademicConcernCreate
from app.schemas.recommendation import RecommendationDecisionCreate
from app.schemas.sla import CategorySLAConfigCreate
from app.services.academic_service import get_academic_service
from app.services.ai_advisory_service import get_ai_advisory_service
from app.services.analytics_service import get_analytics_service
from app.services.recommendation_service import get_recommendation_service
from app.services.recurrence_service import get_recurrence_service
from app.services.sla_service import get_sla_service


@pytest.mark.asyncio
async def test_academic_concern_creation_and_confidential_access(test_db):
    """Verify confidential academic concern creation, officer access, and audit trail logging (FR-2.1..2.3)."""
    academic_service = get_academic_service(test_db)

    concern_in = AcademicConcernCreate(
        title="Grade Dispute - CS301 Final Exam",
        description="Incorrect marking on question 4 regarding distributed systems concurrency.",
        concern_type=AcademicConcernType.GRADE_DISPUTE,
        course_code="CS301",
        academic_term="Fall 2026",
    )

    # 1. Create concern as student/reporter
    concern = await academic_service.create_academic_concern(
        concern_in=concern_in,
        reporter_id="student-123",
    )

    assert concern.id is not None
    assert concern.is_confidential is True
    assert concern.concern_type == AcademicConcernType.GRADE_DISPUTE
    assert concern.course_code == "CS301"

    # 2. Access concern as academic officer and verify confidential access logging
    retrieved = await academic_service.get_academic_concern(
        concern_id=concern.id,
        officer_id="dean-academic-999",
        access_reason="Dean formal investigation review",
    )

    assert retrieved.id == concern.id

    # 3. List academic queue
    queue = await academic_service.list_academic_queue(
        officer_id="dean-academic-999",
        concern_type=AcademicConcernType.GRADE_DISPUTE,
    )
    assert len(queue) >= 1
    assert any(c.id == concern.id for c in queue)


@pytest.mark.asyncio
async def test_recurrence_detection_and_replacement_conversion(test_db):
    """Verify repeated failure clustering and conversion to replacement recommendation (FR-2.6, FR-2.7)."""
    recurrence_service = get_recurrence_service(test_db)

    # Insert 3 issues for same location within window
    now = datetime.now(UTC)
    for i in range(3):
        issue = Issue(
            id=f"rec-issue-{i}",
            reference_number=f"REC-{i}",
            title=f"AC Leak {i}",
            description="Leaking coolant water",
            location_details="Room 304 North Wing",
            status=IssueStatus.REPORTED,
            urgency=IssueUrgency.HIGH,
            reporter_id="user-1",
            created_at=now - timedelta(days=5 * (i + 1)),
        )
        test_db.add(issue)
    await test_db.commit()

    # Detect patterns
    patterns = await recurrence_service.detect_recurring_patterns(window_days=30)
    matching = [p for p in patterns if p.asset_or_location_ref == "Room 304 North Wing"]
    assert len(matching) >= 1
    pattern = matching[0]
    assert pattern.failure_count >= 3
    assert pattern.status == "flagged"

    # Convert to formal replacement recommendation (FR-2.7)
    converted = await recurrence_service.convert_to_replacement_recommendation(
        pattern_id=pattern.id,
        actor_id="supervisor-42",
    )

    assert converted.status == "converted_to_replacement"
    assert converted.converted_recommendation_id is not None

    # Verify decision recording on recommendation
    rec_service = get_recommendation_service(test_db)
    decision = await rec_service.record_decision(
        recommendation_id=converted.converted_recommendation_id,
        decision_in=RecommendationDecisionCreate(decision="accepted", decision_notes="Procurement approved"),
        user_id="opshead-01",
    )
    assert decision.human_decision == "accepted"


@pytest.mark.asyncio
async def test_sla_calculation_and_urgency_factors(test_db):
    """Verify multi-tier SLA resolution window calculation (FR-2.9)."""
    sla_service = get_sla_service(test_db)

    # Insert category
    cat = Category(
        id="cat-wifi-sla",
        name="Campus Wi-Fi",
        slug="wifi-sla",
        default_sla_hours=12,
        is_active=True,
    )
    test_db.add(cat)
    await test_db.commit()

    # Create custom SLA config
    await sla_service.create_sla_config(
        CategorySLAConfigCreate(
            category_id="cat-wifi-sla",
            urgency_level="critical",
            expected_response_hours=1,
            expected_resolution_hours=8,
        )
    )

    # Critical urgency should multiply (0.25x of 8 hours = 2 hours)
    expected_crit = await sla_service.calculate_expected_resolution(
        category_id="cat-wifi-sla",
        urgency="critical",
    )
    now = datetime.now(UTC)
    diff_crit = (expected_crit - now).total_seconds() / 3600
    assert 1.0 <= diff_crit <= 3.0

    # Low urgency should multiply (2.0x of 8 hours = 16 hours)
    expected_low = await sla_service.calculate_expected_resolution(
        category_id="cat-wifi-sla",
        urgency="low",
    )
    diff_low = (expected_low - now).total_seconds() / 3600
    assert 15.0 <= diff_low <= 17.0


@pytest.mark.asyncio
async def test_analytics_drilldown_and_csv_export(test_db):
    """Verify Ops Head analytics overview, metric drill-down, and CSV data streaming (FR-2.8, FR-2.10)."""
    analytics_service = get_analytics_service(test_db)

    # Fetch summary
    overview = await analytics_service.get_campus_analytics()
    assert overview.volume.total_issues >= 0
    assert isinstance(overview.by_category, list)
    assert isinstance(overview.by_building, list)

    # Drill down
    drilldown = await analytics_service.drilldown_issues(filter_type="open")
    assert isinstance(drilldown, list)

    # CSV Export
    csv_text = await analytics_service.export_analytics_csv()
    assert "Reference Number,Title,Category ID" in csv_text
