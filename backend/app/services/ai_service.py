from typing import List


def normalize_prompt(transcript: str) -> str:
    transcript = (transcript or "").strip()
    if not transcript:
        transcript = "con mèo dễ thương"
    return f"{transcript}, line art for kids coloring book, clean outlines"


def mock_lineart_results(n: int) -> List[dict]:
    return [{"id": f"img_{i+1}", "url": f"https://example.com/line{i+1}.png"} for i in range(n)]


def mock_colorize_result() -> dict:
    return {"id": "img_c1", "url": "https://example.com/color1.png"}
