from fastapi import APIRouter, Header

from app.services.quota_service import quota_service

router = APIRouter()


@router.get('/quota')
def get_quota(x_device_id: str = Header(default='dev-local', alias='X-Device-Id')):
    item = quota_service.get_quota(x_device_id)
    return {
        "voiceToLineartRemaining": item["voiceToLineartRemaining"],
        "colorizeRemaining": item["colorizeRemaining"],
        "resetAt": item["resetAt"],
    }
