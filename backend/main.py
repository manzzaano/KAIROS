from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.core.config import settings
from app.routes.tasks import router as tasks_router
from app.routes.auth import router as auth_router

app = FastAPI(title="KAIROS API", version="0.1.0")
app.add_middleware(CORSMiddleware, allow_origins=["*"], allow_credentials=True, allow_methods=["*"], allow_headers=["*"])

app.include_router(tasks_router, prefix="/api/v1/tasks", tags=["tasks"])
app.include_router(auth_router, prefix="/api/v1/auth", tags=["auth"])

@app.get("/health")
async def health():
    return {"status": "ok", "environment": settings.env_name}
