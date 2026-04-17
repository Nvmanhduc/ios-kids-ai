# ios-kids-ai

App vẽ cho trẻ em (iOS/iPad) với luồng GĐ1:
**Voice -> tạo ảnh khung (line-art) -> trẻ chỉnh sửa -> AI tô màu**.

## Trạng thái hiện tại
- ✅ Tài liệu GĐ1 (PRD, API spec, sprint plan)
- ✅ Backend FastAPI mock-first (provider-ready)
- ✅ Quota theo `X-Device-Id`
- ✅ Màn hình vẽ starter bằng SwiftUI + PencilKit

---

## Cấu trúc repo

```text
ios-kids-ai/
├─ PRD_GD1.md
├─ API_SPEC_GD1.md
├─ SPRINT_PLAN_GD1.md
├─ STACK_RECOMMENDATION.md
├─ START_EXECUTION_CHECKLIST.md
├─ backend/
│  ├─ app/
│  │  ├─ main.py
│  │  ├─ config.py
│  │  ├─ routers/
│  │  │  ├─ ai.py
│  │  │  ├─ quota.py
│  │  │  └─ gallery.py
│  │  └─ services/
│  │     ├─ ai_pipeline.py
│  │     ├─ ai_service.py
│  │     ├─ quota_service.py
│  │     └─ providers/openai_provider.py
│  ├─ .env.example
│  ├─ requirements.txt
│  └─ README.md
└─ ios-app/
   ├─ README_DRAWING_SCREEN.md
   └─ KidsAIColoring/
      ├─ KidsAIColoringApp.swift
      ├─ DrawingHomeView.swift
      ├─ DrawingCanvasView.swift
      ├─ DrawingViewModel.swift
      └─ PencilCanvasRepresentable.swift
```

---

## Run backend (local)

```bash
cd backend
python -m venv .venv
.venv\Scripts\activate
pip install -r requirements.txt
copy .env.example .env
uvicorn app.main:app --reload --port 8080
```

Base URL: `http://localhost:8080`

### Endpoints
- `GET /health`
- `POST /v1/ai/voice-to-lineart`
- `POST /v1/ai/lineart-colorize`
- `GET /v1/quota`
- `POST /v1/gallery/save`

> Gửi header `X-Device-Id` để tracking quota.

---

## AI provider mode
Trong `.env`:

- `AI_PROVIDER=mock` (mặc định)
- `AI_PROVIDER=openai` + `OPENAI_API_KEY=...` để dùng real transcription

Hiện tại image generation/colorize vẫn fallback mock an toàn (sẵn interface để nối provider thật).

---

## iOS app starter (drawing screen)
Trong `ios-app/KidsAIColoring` có sẵn màn hình vẽ:
- Brush / Eraser
- Undo / Redo
- Stroke width
- Snapshot canvas

Để chạy:
1. Tạo project iOS SwiftUI mới trong Xcode
2. Copy file trong `ios-app/KidsAIColoring/` vào project
3. Run trên iPhone/iPad

---

## Mục tiêu GĐ1 (MVP)
1. Voice tạo line-art
2. Trẻ chỉnh line-art trên canvas
3. AI tô màu từ line-art đã chỉnh
4. Quota free, không ads

Chi tiết ở: `PRD_GD1.md`

---

## Next steps đề xuất
1. Nối image provider thật cho line-art generation
2. Nối image-to-image thật cho colorize
3. Lưu gallery metadata + file URL thật (R2/S3)
4. Tích hợp iOS app gọi API backend thật

---

## Ghi chú
- Repo đã có `.gitignore` để tránh commit `.env`, cache Python.
- Không commit key vào repo.
