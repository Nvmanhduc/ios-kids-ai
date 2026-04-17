from fastapi import FastAPI
from app.routers import ai, quota, gallery

app = FastAPI(title="Kids AI Coloring API", version="0.1.0")

app.include_router(ai.router, prefix="/v1/ai", tags=["ai"])
app.include_router(quota.router, prefix="/v1", tags=["quota"])
app.include_router(gallery.router, prefix="/v1", tags=["gallery"])

@app.get('/health')
def health():
    return {"ok": True}
