import pytest

from app.models.historical_pattern import HistoricalTrendRecord
from app.models.issue import Issue, IssueAttachment, IssueStatus, IssueUrgency
from app.models.master_data import Building, Category
from app.schemas.search import NLSearchRequest
from app.schemas.tenant import InstitutionCreate
from app.schemas.voice import VoiceTranscriptionRequest
from app.services.historical_analytics_service import get_historical_analytics_service
from app.services.nl_search_service import get_nl_search_service
from app.services.tenant_service import get_tenant_service
from app.services.voice_service import get_voice_service


@pytest.mark.asyncio
async def test_tenant_creation_and_lookup(test_db):
    """Verify multi-institution tenant provisioning and domain/slug resolution (FR-3.4, FR-3.6)."""
    tenant_service = get_tenant_service(test_db)

    inst_in = InstitutionCreate(
        name="Global Apex Institute of Technology",
        slug="global-apex",
        domain="globalapex.edu",
        settings={"timezone": "UTC", "allow_guest_reports": False},
    )

    # 1. Provision institution
    created = await tenant_service.create_institution(inst_in)
    assert created.id is not None
    assert created.slug == "global-apex"
    assert created.domain == "globalapex.edu"
    assert created.is_active is True

    # 2. Lookup by domain
    by_domain = await tenant_service.get_institution_by_domain("globalapex.edu")
    assert by_domain is not None
    assert by_domain.id == created.id

    # 3. Lookup by slug
    by_slug = await tenant_service.get_institution_by_slug("global-apex")
    assert by_slug is not None
    assert by_slug.name == "Global Apex Institute of Technology"

    # 4. List institutions
    institutions = await tenant_service.list_institutions(active_only=True)
    assert len(institutions) >= 1
    assert any(inst.id == created.id for inst in institutions)


@pytest.mark.asyncio
async def test_voice_transcription_and_classification(test_db):
    """Verify voice audio transcription and automatic AI advisory classification pipeline (FR-3.1)."""
    # Create master data category for classification matching
    category = Category(
        id="cat-plumbing-1",
        name="Plumbing & Water Supply",
        slug="plumbing",
        description="Pipes, taps, washrooms, water leakage",
        default_sla_hours=4,
        is_active=True,
    )
    test_db.add(category)

    # Create dummy attachment metadata
    attachment = IssueAttachment(
        id="att-voice-001",
        issue_id=None,
        file_name="voice_water_leak_recording.m4a",
        file_type="audio/m4a",
        storage_bucket="attachments",
        storage_path="audio/voice_water_leak_recording.m4a",
        size_bytes=48000,
        uploaded_by="user-123",
    )
    test_db.add(attachment)
    await test_db.commit()

    voice_service = get_voice_service(test_db)
    request = VoiceTranscriptionRequest(
        attachment_id="att-voice-001",
        audio_format="m4a",
        language_code="en",
    )

    response = await voice_service.transcribe_audio_attachment(request, _user_id="user-123")

    assert response.transcribed_text is not None
    assert len(response.transcribed_text) > 10
    assert response.confidence >= 0.90
    assert response.duration_seconds > 0
    assert response.classification is not None
    assert response.classification.suggested_urgency in ["medium", "high", "critical"]


@pytest.mark.asyncio
async def test_natural_language_search_parsing_and_execution(test_db):
    """Verify natural language query parsing and dynamic issue filter execution (FR-3.2, FR-3.3)."""
    # Seed master data
    category = Category(
        id="cat-wifi-1",
        name="Wi-Fi & Network",
        slug="wifi",
        description="Campus internet and wireless coverage",
        default_sla_hours=8,
        is_active=True,
    )
    building = Building(
        id="bldg-science-1",
        name="Science Block",
        code="SCI",
        is_active=True,
    )
    test_db.add_all([category, building])
    await test_db.commit()

    # Seed issues
    issue1 = Issue(
        id="iss-wifi-001",
        reference_number="CC-2026-9001",
        title="Unresolved Wi-Fi router packet loss",
        description="The Wi-Fi access point in Science Block is dropping connection every 5 minutes.",
        category_id="cat-wifi-1",
        building_id="bldg-science-1",
        status=IssueStatus.INVESTIGATING,
        urgency=IssueUrgency.HIGH,
        reporter_id="student-1",
    )
    issue2 = Issue(
        id="iss-wifi-002",
        reference_number="CC-2026-9002",
        title="Resolved electrical switchboard fault",
        description="Repaired broken power switch.",
        category_id=None,
        building_id=None,
        status=IssueStatus.RESOLVED,
        urgency=IssueUrgency.LOW,
        reporter_id="student-2",
    )
    test_db.add_all([issue1, issue2])
    await test_db.commit()

    nl_service = get_nl_search_service(test_db)

    search_req = NLSearchRequest(
        query_text="show me unresolved wifi issues in Science Block",
        limit=10,
    )

    result = await nl_service.parse_and_execute_search(search_req, _user_id="staff-1")

    assert result.original_query == search_req.query_text
    assert result.parsed_filters.category_slug == "wifi"
    assert result.parsed_filters.building_name == "Science Block"
    assert result.parsed_filters.is_unresolved is True
    assert result.total_matched >= 1
    assert result.results[0].id == "iss-wifi-001"


@pytest.mark.asyncio
async def test_historical_trend_analytics_and_seasonal_patterns(test_db):
    """Verify multi-year longitudinal pattern mining and seasonal spike detection (FR-3.5)."""
    # Seed historical records
    rec1 = HistoricalTrendRecord(
        id="trend-2025-q2",
        institution_id="inst-1",
        category_id=None,
        year=2025,
        quarter=2,
        month=6,
        total_volume=412,
        avg_resolution_hours=14.5,
        seasonal_spike_flag=True,
        pattern_summary="Summer AC compressor failures surge.",
        aggregated_metrics={"spike_percentage": 48},
    )
    rec2 = HistoricalTrendRecord(
        id="trend-2025-q3",
        institution_id="inst-1",
        category_id=None,
        year=2025,
        quarter=3,
        month=9,
        total_volume=380,
        avg_resolution_hours=9.2,
        seasonal_spike_flag=True,
        pattern_summary="Semester onboarding Wi-Fi saturation.",
        aggregated_metrics={"spike_percentage": 62},
    )
    test_db.add_all([rec1, rec2])
    await test_db.commit()

    analytics_service = get_historical_analytics_service(test_db)
    response = await analytics_service.get_multi_year_trends(institution_id="inst-1")

    assert len(response.records) >= 2
    assert len(response.identified_seasonal_patterns) >= 2
    assert len(response.long_term_recommendations) >= 2
    assert any("HVAC" in p or "AC" in p for p in response.identified_seasonal_patterns)
    assert any(rec.seasonal_spike_flag for rec in response.records)
