from pydantic import BaseModel
import os


class Settings(BaseModel):
    app_name: str = os.getenv("APP_NAME", "Kids AI Coloring API")
    daily_voice_quota: int = int(os.getenv("DAILY_VOICE_QUOTA", "3"))
    daily_colorize_quota: int = int(os.getenv("DAILY_COLORIZE_QUOTA", "5"))
    quota_store_path: str = os.getenv("QUOTA_STORE_PATH", "./data/quota_store.json")


settings = Settings()
