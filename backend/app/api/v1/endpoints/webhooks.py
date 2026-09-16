from fastapi import APIRouter, Request, status

router = APIRouter()


@router.post("/brevo")
async def brevo_webhook(request: Request):
    """Signed delivery webhook for Brevo email status (FR-NOTIF-20b)."""
    return {"status": "received"}


@router.post("/resend")
async def resend_webhook(request: Request):
    """Signed delivery webhook for Resend failover email status (FR-NOTIF-20b)."""
    return {"status": "received"}


@router.post("/whatsapp")
async def whatsapp_webhook(request: Request):
    """Signed webhook for Meta WhatsApp delivery feedback (FR-NOTIF-20b)."""
    return {"status": "received"}
