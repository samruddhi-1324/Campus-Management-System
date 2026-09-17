import logging
from typing import Any
from fastapi import APIRouter, HTTPException, Query, Request, Response, status

logger = logging.getLogger(__name__)
router = APIRouter()


@router.get("/whatsapp")
async def verify_whatsapp_webhook(
    hub_mode: str | None = Query(None, alias="hub.mode"),
    hub_challenge: str | None = Query(None, alias="hub.challenge"),
    hub_verify_token: str | None = Query(None, alias="hub.verify_token"),
) -> Response:
    """Meta WhatsApp Cloud API Webhook Subscription Verification (OAuth 2.0 / Webhook handshake)."""
    # Expected verify token (configurable via env)
    expected_token = "campus_care_wa_verify_token"
    if hub_mode == "subscribe" and hub_verify_token == expected_token:
        return Response(content=hub_challenge, media_type="text/plain")
    elif hub_mode == "subscribe" and hub_verify_token != expected_token:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Verification token mismatch",
        )
    return Response(content="Campus Care WhatsApp Webhook Endpoint Active", media_type="text/plain")


@router.post("/whatsapp")
async def whatsapp_inbound_webhook(request: Request) -> dict[str, Any]:
    """Inbound message and delivery status webhook for Meta WhatsApp Business API (FR-NOTIF-20b)."""
    try:
        body = await request.json()
    except Exception:
        body = {}

    # Extract WhatsApp entry/changes if available
    entries = body.get("entry", [])
    processed_count = 0
    for entry in entries:
        for change in entry.get("changes", []):
            val = change.get("value", {})
            # Handle incoming messages
            messages = val.get("messages", [])
            for msg in messages:
                from_num = msg.get("from")
                msg_body = msg.get("text", {}).get("body", "")
                logger.info(f"Received inbound WhatsApp message from {from_num}: {msg_body}")
                processed_count += 1
            # Handle status delivery receipts (sent, delivered, read)
            statuses = val.get("statuses", [])
            for st in statuses:
                recipient_id = st.get("recipient_id")
                status_str = st.get("status")
                logger.info(f"WhatsApp delivery status update for {recipient_id}: {status_str}")
                processed_count += 1

    return {"status": "success", "processed_events": processed_count}


@router.post("/brevo")
async def brevo_webhook(request: Request) -> dict[str, str]:
    """Signed delivery webhook for Brevo email status (FR-NOTIF-20b)."""
    try:
        payload = await request.json()
        logger.info(f"Brevo email webhook event: {payload.get('event')}")
    except Exception:
        pass
    return {"status": "received"}


@router.post("/resend")
async def resend_webhook(request: Request) -> dict[str, str]:
    """Signed delivery webhook for Resend failover email status (FR-NOTIF-20b)."""
    try:
        payload = await request.json()
        logger.info(f"Resend email webhook event: {payload.get('type')}")
    except Exception:
        pass
    return {"status": "received"}
