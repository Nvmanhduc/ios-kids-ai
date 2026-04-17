from __future__ import annotations

from dataclasses import dataclass
from datetime import datetime, timedelta, timezone
import json
import os
from threading import Lock

from app.config import settings

_lock = Lock()


@dataclass
class QuotaState:
    voice_remaining: int
    colorize_remaining: int
    reset_at: str


class QuotaService:
    def __init__(self, path: str):
        self.path = path
        folder = os.path.dirname(path)
        if folder:
            os.makedirs(folder, exist_ok=True)

    @staticmethod
    def _next_reset_iso() -> str:
        # Reset every day at 00:00 Asia/Saigon == 17:00 UTC previous day.
        now = datetime.now(timezone.utc)
        reset = now.replace(hour=17, minute=0, second=0, microsecond=0)
        if now >= reset:
            reset = reset + timedelta(days=1)
        return reset.isoformat()

    def _load_all(self) -> dict:
        if not os.path.exists(self.path):
            return {}
        with open(self.path, "r", encoding="utf-8") as f:
            try:
                return json.load(f)
            except json.JSONDecodeError:
                return {}

    def _save_all(self, data: dict) -> None:
        with open(self.path, "w", encoding="utf-8") as f:
            json.dump(data, f, ensure_ascii=False, indent=2)

    def _fresh_state(self) -> dict:
        return {
            "voiceToLineartRemaining": settings.daily_voice_quota,
            "colorizeRemaining": settings.daily_colorize_quota,
            "resetAt": self._next_reset_iso(),
        }

    def _is_expired(self, reset_at: str) -> bool:
        try:
            dt = datetime.fromisoformat(reset_at)
        except ValueError:
            return True
        return datetime.now(timezone.utc) >= dt

    def get_quota(self, device_id: str) -> dict:
        with _lock:
            data = self._load_all()
            item = data.get(device_id)
            if not item or self._is_expired(item.get("resetAt", "")):
                item = self._fresh_state()
                data[device_id] = item
                self._save_all(data)
            return item

    def consume_voice(self, device_id: str) -> dict | None:
        with _lock:
            data = self._load_all()
            item = data.get(device_id)
            if not item or self._is_expired(item.get("resetAt", "")):
                item = self._fresh_state()
            if item["voiceToLineartRemaining"] <= 0:
                data[device_id] = item
                self._save_all(data)
                return None
            item["voiceToLineartRemaining"] -= 1
            data[device_id] = item
            self._save_all(data)
            return item

    def consume_colorize(self, device_id: str) -> dict | None:
        with _lock:
            data = self._load_all()
            item = data.get(device_id)
            if not item or self._is_expired(item.get("resetAt", "")):
                item = self._fresh_state()
            if item["colorizeRemaining"] <= 0:
                data[device_id] = item
                self._save_all(data)
                return None
            item["colorizeRemaining"] -= 1
            data[device_id] = item
            self._save_all(data)
            return item


quota_service = QuotaService(settings.quota_store_path)
