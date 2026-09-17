from typing import Any


class AIAdvisoryClient:
    """Asynchronous LLM advisory subsystem interface (FR-AI-01..20).

    Enforces human-in-the-loop and graceful degradation when the AI service is unavailable.
    """

    async def classify_issue(self, title: str, description: str, location: str) -> dict[str, Any]:
        """Suggest category, urgency, and missing information items (FR-AI-01, FR-AI-02)."""
        return {
            "suggested_category": None,
            "suggested_urgency": "medium",
            "urgency_rationale": "Default baseline urgency pending LLM evaluation",
            "missing_information": [],
            "confidence": 0.0,
            "is_ai_generated": True,
        }

    async def check_duplicate(self, issue_id: str, description: str, location: str) -> dict[str, Any]:
        """Detect duplicate issues in the same vicinity without auto-merging (FR-AI-03)."""
        return {
            "potential_duplicate_ids": [],
            "similarity_score": 0.0,
            "rationale": "",
        }

    async def draft_status_update(self, issue_context: dict[str, Any], status: str) -> str:
        """Draft a polite, informative status update for human review (FR-AI-06)."""
        return f"Update regarding your issue: Current status is now {status}."


ai_client = AIAdvisoryClient()
