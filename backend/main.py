from contextlib import asynccontextmanager

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.core.config import settings
from app.routes.auth import router as auth_router
from app.routes.confessional import router as confessional_router
from app.routes.tasks import router as tasks_router


def _seed_demo_user() -> None:
    from app.core.database import SessionLocal
    from app.models.user import User
    from app.services.auth_service import hash_password

    db = SessionLocal()
    try:
        if not db.query(User).filter(User.id == 1).first():
            db.add(User(
                id=1,
                email="demo@example.com",
                username="aspirant",
                hashed_password=hash_password("demo1234"),
            ))
            db.commit()
    except Exception:
        db.rollback()
    finally:
        db.close()


@asynccontextmanager
async def lifespan(app: FastAPI):
    from app.core.database import create_tables
    create_tables()
    _seed_demo_user()
    yield


app = FastAPI(title="KAIROS API", version="0.1.0", lifespan=lifespan)
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(tasks_router, prefix="/api/v1/tasks", tags=["tasks"])
app.include_router(auth_router, prefix="/api/v1/auth", tags=["auth"])
app.include_router(confessional_router, prefix="/api/v1/confessional", tags=["confessional"])


@app.get("/health")
async def health():
    return {"status": "ok", "environment": settings.env_name}
