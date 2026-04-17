from __future__ import annotations

import os
from dataclasses import dataclass

from app.services.ai_service import mock_colorize_result, mock_lineart_results, normalize_prompt


@dataclass
class VoiceLineartResult:
    transcript: str
    normalized_prompt: str
    results: list[dict]


@dataclass
class ColorizeResult:
    result: dict


class AIPipeline:
    def __init__(self):
        self.provider_name = os.getenv("AI_PROVIDER", "mock").lower()
        self.openai_api_key = os.getenv("OPENAI_API_KEY", "")
        self._provider = None

        if self.provider_name == "openai" and self.openai_api_key:
            try:
                from app.services.providers.openai_provider import OpenAIProvider

                self._provider = OpenAIProvider(api_key=self.openai_api_key)
            except Exception:
                self._provider = None

    def voice_to_lineart(self, audio_bytes: bytes, filename: str, n: int = 1) -> VoiceLineartResult:
        transcript = "con ho co canh"

        if self._provider is not None:
            try:
                transcript = self._provider.transcribe_audio(audio_bytes=audio_bytes, filename=filename) or transcript
            except Exception:
                # fallback to mock transcript
                pass

        normalized = normalize_prompt(transcript)

        # Real image generation is intentionally stubbed for now; fallback to mock URLs.
        results = mock_lineart_results(n)
        return VoiceLineartResult(transcript=transcript, normalized_prompt=normalized, results=results)

    def lineart_to_color(self, lineart_bytes: bytes, style: str) -> ColorizeResult:
        if self._provider is not None:
            try:
                real = self._provider.colorize_from_lineart(lineart_bytes=lineart_bytes, style=style)
                if real:
                    return ColorizeResult(result=real)
            except Exception:
                pass

        return ColorizeResult(result=mock_colorize_result())


ai_pipeline = AIPipeline()
