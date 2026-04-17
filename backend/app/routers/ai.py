from fastapi import APIRouter, UploadFile, File, Form, HTTPException, Header

from app.services.ai_pipeline import ai_pipeline
from app.services.quota_service import quota_service

router = APIRouter()


@router.post('/voice-to-lineart')
async def voice_to_lineart(
    audio: UploadFile = File(...),
    lang: str = Form('vi'),
    n: int = Form(1),
    x_device_id: str = Header(default='dev-local', alias='X-Device-Id'),
):
    if n < 1 or n > 3:
        raise HTTPException(status_code=400, detail='n must be 1..3')

    quota = quota_service.consume_voice(x_device_id)
    if quota is None:
        raise HTTPException(status_code=429, detail='429_QUOTA_EXCEEDED')

    audio_bytes = await audio.read()
    result = ai_pipeline.voice_to_lineart(audio_bytes=audio_bytes, filename=audio.filename or 'audio.m4a', n=n)

    return {
        "requestId": "req_voice_001",
        "transcript": result.transcript,
        "normalizedPrompt": result.normalized_prompt,
        "results": result.results,
        "quota": {
            "voiceToLineartRemaining": quota["voiceToLineartRemaining"],
            "colorizeRemaining": quota["colorizeRemaining"],
        },
    }


@router.post('/lineart-colorize')
async def lineart_colorize(
    lineart: UploadFile = File(...),
    style: str = Form('cute'),
    x_device_id: str = Header(default='dev-local', alias='X-Device-Id'),
):
    if style not in ['cute', 'natural', 'vivid']:
        raise HTTPException(status_code=400, detail='invalid style')

    quota = quota_service.consume_colorize(x_device_id)
    if quota is None:
        raise HTTPException(status_code=429, detail='429_QUOTA_EXCEEDED')

    lineart_bytes = await lineart.read()
    result = ai_pipeline.lineart_to_color(lineart_bytes=lineart_bytes, style=style)

    return {
        "requestId": "req_color_001",
        "result": result.result,
        "quota": {
            "voiceToLineartRemaining": quota["voiceToLineartRemaining"],
            "colorizeRemaining": quota["colorizeRemaining"],
        },
    }
