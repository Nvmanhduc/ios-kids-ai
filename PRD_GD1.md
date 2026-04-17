# PRD GĐ1 — Kids AI Coloring (Free)

## 1) Mục tiêu
Xây app iOS/iPad cho trẻ em:
- Voice tạo ảnh khung (line-art)
- Trẻ chỉnh sửa khung trên canvas
- AI tô màu từ khung đã chỉnh
- Miễn phí, không quảng cáo, giới hạn lượt AI

## 2) User Flow chính
1. Nhấn mic, nói ý tưởng ("con hổ có cánh")
2. Voice -> text, cho phép sửa prompt nhanh
3. AI tạo line-art (1-3 kết quả)
4. Trẻ chỉnh nét trên canvas
5. Nhấn "AI tô màu"
6. Nhận ảnh màu, lưu gallery

## 3) Scope GĐ1
### Must-have
- Canvas: brush, eraser, size, undo/redo, zoom/pan
- Voice -> text -> line-art
- Edit line-art
- Line-art -> colorize
- Gallery lưu 3 version:
  - lineart_original
  - lineart_edited
  - colorized_result
- Quota free:
  - voice->lineart: 3 lượt/ngày
  - colorize: 5 lượt/ngày

### Out of scope
- Subscription/paywall
- Video/3D
- POD bán hàng

## 4) Yêu cầu chức năng
- FR01: Tạo canvas mới < 1 thao tác
- FR02: Ghi âm tối đa 10s/lượt
- FR03: Sửa prompt trước khi generate
- FR04: Line-art trả về <= 15s (P95)
- FR05: Colorize trả về <= 20s (P95)
- FR06: Quota hiển thị rõ + reset theo ngày
- FR07: Fail server không trừ quota

## 5) Yêu cầu phi chức năng
- Crash-free > 99%
- App launch < 2.5s
- Local save ổn định khi app bị kill
- Content moderation prompt cơ bản

## 6) KPI GĐ1
- % hoàn thành flow voice->line->color
- Tỷ lệ accept ảnh AI
- D1 retention
- Số lượt AI/user/ngày

## 7) Rủi ro
- ASR trẻ em nhận sai -> cho sửa prompt
- AI lệch ý -> regenerate + preset style
- Cost AI cao -> quota cứng + resize + cache
