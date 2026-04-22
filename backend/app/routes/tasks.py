import logging
import math
from datetime import datetime
from typing import List, Optional

from fastapi import APIRouter, Depends, HTTPException, Query
from fastapi import status as http_status
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer
from jose import JWTError, jwt
from pydantic import BaseModel, Field
from sqlalchemy.orm import Session

from app.core.config import settings
from app.core.database import get_db
from app.models.task import Task
from app.schemas.task import (
    PayDebtRequest,
    ProductivityDebtResponse,
    TaskCreate,
    TaskListResponse,
    TaskResponse,
)
from app.services.auth_service import ALGORITHM
from app.services.gemini_service import GeminiOptimizer
from app.services.task_service import (
    calculate_streak_days,
    get_or_create_debt,
    update_debt_on_abandon,
    update_debt_on_complete,
)

logger = logging.getLogger(__name__)
router = APIRouter()
_security = HTTPBearer()


def get_current_user_id(
    credentials: HTTPAuthorizationCredentials = Depends(_security),
) -> int:
    try:
        payload = jwt.decode(credentials.credentials, settings.jwt_secret, algorithms=[ALGORITHM])
        return int(payload["sub"])
    except (JWTError, KeyError, ValueError):
        raise HTTPException(
            status_code=http_status.HTTP_401_UNAUTHORIZED,
            detail="Token inválido",
        )


# ─── Gemini optimize (existing) ───────────────────────────────────────────────

class _TaskRequest(BaseModel):
    title: str
    priority: int = Field(..., ge=1, le=3)
    energy: int = Field(..., ge=1, le=5)


class _TaskOptimizeRequest(BaseModel):
    tasks: List[_TaskRequest]


class _TaskOptimizeResponse(BaseModel):
    optimized: List[_TaskRequest]
    explanation: str


@router.post("/optimize", response_model=_TaskOptimizeResponse)
async def optimize(payload: _TaskOptimizeRequest) -> _TaskOptimizeResponse:
    logger.info("POST /optimize received with %d tasks", len(payload.tasks))
    if not settings.gemini_api_key:
        raise HTTPException(status_code=503, detail="Gemini API key not configured")
    optimizer = GeminiOptimizer(api_key=settings.gemini_api_key)
    tasks_dict = [t.model_dump() for t in payload.tasks]
    try:
        result = await optimizer.optimize_tasks(tasks_dict)
    except Exception as exc:
        logger.exception("GeminiOptimizer failed: %s", exc)
        raise HTTPException(status_code=503, detail="Gemini service unavailable") from exc
    if "optimized" not in result or "explanation" not in result:
        raise HTTPException(status_code=503, detail="Malformed optimizer response")
    logger.info("POST /optimize succeeded")
    return _TaskOptimizeResponse(
        optimized=[_TaskRequest(**t) for t in result["optimized"]],
        explanation=result["explanation"],
    )


# ─── Debt (before /{task_id} to avoid route collision) ────────────────────────

@router.get("/debt", response_model=ProductivityDebtResponse)
def get_debt(
    user_id: int = Depends(get_current_user_id),
    db: Session = Depends(get_db),
) -> ProductivityDebtResponse:
    debt = get_or_create_debt(user_id, db)
    streak = calculate_streak_days(user_id, db)
    return ProductivityDebtResponse(
        total_debt_minutes=debt.total_debt_minutes,
        free_time_minutes=debt.free_time_minutes,
        last_updated=debt.last_updated,
        streak_days=streak,
    )


@router.post("/debt/pay", response_model=ProductivityDebtResponse)
def pay_debt(
    payload: PayDebtRequest,
    user_id: int = Depends(get_current_user_id),
    db: Session = Depends(get_db),
) -> ProductivityDebtResponse:
    debt = get_or_create_debt(user_id, db)
    debt.total_debt_minutes = max(0, debt.total_debt_minutes - payload.minutes_paid)
    debt.last_updated = datetime.utcnow()
    db.commit()
    db.refresh(debt)
    streak = calculate_streak_days(user_id, db)
    return ProductivityDebtResponse(
        total_debt_minutes=debt.total_debt_minutes,
        free_time_minutes=debt.free_time_minutes,
        last_updated=debt.last_updated,
        streak_days=streak,
    )


# ─── Task CRUD ────────────────────────────────────────────────────────────────

@router.post("/create", response_model=TaskResponse, status_code=http_status.HTTP_201_CREATED)
def create_task(
    payload: TaskCreate,
    user_id: int = Depends(get_current_user_id),
    db: Session = Depends(get_db),
) -> TaskResponse:
    task = Task(
        user_id=user_id,
        title=payload.title,
        priority=payload.priority,
        energy=payload.energy,
        estimated_minutes=payload.estimated_minutes,
        latitude=payload.latitude,
        longitude=payload.longitude,
    )
    db.add(task)
    db.commit()
    db.refresh(task)
    return task


@router.get("/list", response_model=TaskListResponse)
def list_tasks(
    status: Optional[str] = Query(default="all", pattern="^(all|completed|abandoned)$"),
    user_id: int = Depends(get_current_user_id),
    db: Session = Depends(get_db),
) -> TaskListResponse:
    query = db.query(Task).filter(Task.user_id == user_id)
    if status == "completed":
        query = query.filter(Task.completed.is_(True))
    elif status == "abandoned":
        query = query.filter(Task.abandoned.is_(True))
    tasks = query.order_by(Task.created_at.desc()).all()
    return TaskListResponse(
        tasks=tasks,
        total_tasks=len(tasks),
        completed=sum(1 for t in tasks if t.completed),
        abandoned=sum(1 for t in tasks if t.abandoned),
    )


@router.get("/{task_id}", response_model=TaskResponse)
def get_task(
    task_id: int,
    user_id: int = Depends(get_current_user_id),
    db: Session = Depends(get_db),
) -> TaskResponse:
    task = db.query(Task).filter(Task.id == task_id, Task.user_id == user_id).first()
    if not task:
        raise HTTPException(status_code=404, detail="Tarea no encontrada")
    return task


@router.put("/{task_id}/complete", response_model=TaskResponse)
def complete_task(
    task_id: int,
    user_id: int = Depends(get_current_user_id),
    db: Session = Depends(get_db),
) -> TaskResponse:
    task = db.query(Task).filter(Task.id == task_id, Task.user_id == user_id).first()
    if not task:
        raise HTTPException(status_code=404, detail="Tarea no encontrada")
    if task.completed:
        raise HTTPException(status_code=400, detail="Tarea ya completada")
    if task.abandoned:
        raise HTTPException(status_code=400, detail="Tarea abandonada, no se puede completar")
    task.completed = True
    task.completed_at = datetime.utcnow()
    db.commit()
    update_debt_on_complete(user_id, task.estimated_minutes, db)
    db.refresh(task)
    return task


@router.put("/{task_id}/abandon", response_model=TaskResponse)
def abandon_task(
    task_id: int,
    user_id: int = Depends(get_current_user_id),
    db: Session = Depends(get_db),
) -> TaskResponse:
    task = db.query(Task).filter(Task.id == task_id, Task.user_id == user_id).first()
    if not task:
        raise HTTPException(status_code=404, detail="Tarea no encontrada")
    if task.abandoned:
        raise HTTPException(status_code=400, detail="Tarea ya abandonada")
    if task.completed:
        raise HTTPException(status_code=400, detail="No se puede abandonar una tarea completada")
    task.abandoned = True
    task.abandoned_at = datetime.utcnow()
    db.commit()
    update_debt_on_abandon(user_id, task.estimated_minutes, db)
    db.refresh(task)
    return task


@router.delete("/{task_id}")
def delete_task(
    task_id: int,
    user_id: int = Depends(get_current_user_id),
    db: Session = Depends(get_db),
) -> dict:
    task = db.query(Task).filter(Task.id == task_id, Task.user_id == user_id).first()
    if not task:
        raise HTTPException(status_code=404, detail="Tarea no encontrada")
    if task.completed or task.abandoned:
        raise HTTPException(status_code=400, detail="No se puede eliminar tarea completada o abandonada")
    db.delete(task)
    db.commit()
    return {"deleted": True}


# ─── Geofence validation ──────────────────────────────────────────────────────

_GEOFENCE_RADIUS_M = 100.0
_EARTH_RADIUS_M = 6_371_000.0


def _haversine(lat1: float, lon1: float, lat2: float, lon2: float) -> float:
    phi1, phi2 = math.radians(lat1), math.radians(lat2)
    dphi = math.radians(lat2 - lat1)
    dlam = math.radians(lon2 - lon1)
    a = math.sin(dphi / 2) ** 2 + math.cos(phi1) * math.cos(phi2) * math.sin(dlam / 2) ** 2
    return 2 * _EARTH_RADIUS_M * math.asin(math.sqrt(a))


class _ValidateZoneRequest(BaseModel):
    user_latitude: float
    user_longitude: float


class _ValidateZoneResponse(BaseModel):
    task_id: int
    is_in_zone: bool
    user_lat: float
    user_lon: float
    task_lat: Optional[float]
    task_lon: Optional[float]
    distance_meters: float


@router.post("/{task_id}/validate-zone", response_model=_ValidateZoneResponse)
def validate_zone(
    task_id: int,
    payload: _ValidateZoneRequest,
    user_id: int = Depends(get_current_user_id),
    db: Session = Depends(get_db),
) -> _ValidateZoneResponse:
    task = db.query(Task).filter(Task.id == task_id, Task.user_id == user_id).first()
    if not task:
        raise HTTPException(status_code=404, detail="Tarea no encontrada")

    if task.latitude is None or task.longitude is None:
        return _ValidateZoneResponse(
            task_id=task_id,
            is_in_zone=True,
            user_lat=payload.user_latitude,
            user_lon=payload.user_longitude,
            task_lat=None,
            task_lon=None,
            distance_meters=0.0,
        )

    distance = _haversine(
        payload.user_latitude,
        payload.user_longitude,
        task.latitude,
        task.longitude,
    )
    return _ValidateZoneResponse(
        task_id=task_id,
        is_in_zone=distance <= _GEOFENCE_RADIUS_M,
        user_lat=payload.user_latitude,
        user_lon=payload.user_longitude,
        task_lat=task.latitude,
        task_lon=task.longitude,
        distance_meters=round(distance, 2),
    )
