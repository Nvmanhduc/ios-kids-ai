from fastapi import APIRouter
from pydantic import BaseModel

router = APIRouter()

class SaveGalleryRequest(BaseModel):
    projectId: str
    lineartOriginalUrl: str
    lineartEditedUrl: str
    colorizedUrl: str

@router.post('/gallery/save')
def save_gallery(payload: SaveGalleryRequest):
    return {"ok": True, "projectId": payload.projectId}
