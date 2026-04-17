# Run backend (mock-first, provider-ready)

```bash
cd backend
python -m venv .venv
.venv\\Scripts\\activate
pip install -r requirements.txt
copy .env.example .env
uvicorn app.main:app --reload --port 8080
```

## Env switches
- `AI_PROVIDER=mock` (default) -> always uses mock lineart/colorize
- `AI_PROVIDER=openai` + `OPENAI_API_KEY=...` -> uses real OpenAI transcription for voice

## Endpoints
- GET /health
- POST /v1/ai/voice-to-lineart
- POST /v1/ai/lineart-colorize
- GET /v1/quota
- POST /v1/gallery/save

## Headers
Send `X-Device-Id` for quota tracking (example: `kid-device-001`).
