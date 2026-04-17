# API Spec GĐ1 (Image-first)

Base URL: `/v1`
Auth: `X-Device-Id` (GĐ1 anonymous)

---
## 1) POST /ai/voice-to-lineart
Voice -> transcript -> line-art

### Request (multipart/form-data)
- `audio`: file m4a/wav (required)
- `lang`: `vi` (optional, default `vi`)
- `child_safe`: `true|false` (default true)
- `n`: số ảnh trả về (default 1, max 3)

### Response 200
```json
{
  "requestId": "req_123",
  "transcript": "con hổ có cánh",
  "normalizedPrompt": "cute winged tiger line art for kids coloring book",
  "results": [
    {"id":"img_1","url":"https://.../line1.png"}
  ],
  "quota": {"voiceToLineartRemaining": 2, "colorizeRemaining": 5}
}
```

### Errors
- `429_QUOTA_EXCEEDED`
- `400_AUDIO_INVALID`
- `422_PROMPT_BLOCKED`
- `500_AI_PROVIDER_ERROR`

---
## 2) POST /ai/lineart-colorize
Colorize từ ảnh khung đã chỉnh

### Request (multipart/form-data)
- `lineart`: png/jpg (required)
- `style`: `cute|natural|vivid` (default `cute`)
- `paletteHint`: string (optional)
- `strength`: 0.0 - 1.0 (optional, default 0.7)

### Response 200
```json
{
  "requestId": "req_456",
  "result": {"id":"img_c1","url":"https://.../color1.png"},
  "quota": {"voiceToLineartRemaining": 2, "colorizeRemaining": 4}
}
```

### Errors
- `429_QUOTA_EXCEEDED`
- `400_IMAGE_INVALID`
- `422_CONTENT_BLOCKED`
- `500_AI_PROVIDER_ERROR`

---
## 3) GET /quota
```json
{
  "voiceToLineartRemaining": 2,
  "colorizeRemaining": 4,
  "resetAt": "2026-04-18T00:00:00+07:00"
}
```

---
## 4) POST /gallery/save
Lưu metadata 3 phiên bản tranh

### Request JSON
```json
{
  "projectId": "p_001",
  "lineartOriginalUrl": "https://.../line0.png",
  "lineartEditedUrl": "https://.../line_edited.png",
  "colorizedUrl": "https://.../color.png"
}
```

### Response
```json
{"ok": true, "projectId": "p_001"}
```
