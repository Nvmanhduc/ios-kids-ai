from __future__ import annotations

from typing import Optional

from openai import OpenAI


class OpenAIProvider:
    def __init__(self, api_key: str, model: str = "gpt-4o-mini-transcribe"):
        self.client = OpenAI(api_key=api_key)
        self.transcribe_model = model

    def transcribe_audio(self, audio_bytes: bytes, filename: str = "audio.m4a") -> str:
        # Uses OpenAI audio transcription; returns plain transcript.
        from io import BytesIO

        bio = BytesIO(audio_bytes)
        bio.name = filename
        result = self.client.audio.transcriptions.create(
            model=self.transcribe_model,
            file=bio,
        )
        text = getattr(result, "text", None) or ""
        return text.strip()

    def generate_lineart_urls(self, prompt: str, n: int = 1) -> list[dict]:
        # Placeholder for future real image provider integration.
        # Keep interface ready; fallback handled at pipeline layer.
        return []

    def colorize_from_lineart(self, lineart_bytes: bytes, style: str) -> Optional[dict]:
        # Placeholder for future real image provider integration.
        return None
