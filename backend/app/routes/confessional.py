import json
import logging

from fastapi import APIRouter, Depends
from fastapi.responses import StreamingResponse
from sqlalchemy.orm import Session

from app.core.config import settings
from app.core.database import get_db
from app.models.task import Task
from app.routes.tasks import get_current_user_id
from app.services.gemini_service import GeminiService
from app.services.task_service import calculate_streak_days, get_or_create_debt

logger = logging.getLogger(__name__)
router = APIRouter()


@router.post("/reflect")
async def get_reflection(
    user_id: int = Depends(get_current_user_id),
    db: Session = Depends(get_db),
):
    """
    POST /confessional/reflect
    Reflexión estoica personalizada en streaming SSE.

    Response: text/event-stream
      data: "<json-encoded chunk>"\n\n
      ...
      data: "[DONE]"\n\n
    """
    debt = get_or_create_debt(user_id, db)
    streak = calculate_streak_days(user_id, db)

    tasks = db.query(Task).filter(Task.user_id == user_id).all()
    completed = sum(1 for t in tasks if t.completed)
    abandoned = sum(1 for t in tasks if t.abandoned)

    service = GeminiService(api_key=settings.gemini_api_key)

    async def stream_generator():
        try:
            async for chunk in service.generate_debt_reflection(
                total_debt_minutes=debt.total_debt_minutes,
                streak_days=streak,
                sessions_completed=completed,
                recent_abandons=abandoned,
            ):
                yield f"data: {json.dumps(chunk)}\n\n"
        except Exception as exc:
            logger.exception("SSE stream error: %s", exc)
            yield f"data: {json.dumps('Error generando reflexión.')}\n\n"
        finally:
            yield 'data: "[DONE]"\n\n'

    return StreamingResponse(
        stream_generator(),
        media_type="text/event-stream",
        headers={
            "Cache-Control": "no-cache",
            "X-Accel-Buffering": "no",
        },
    )


@router.get("/debt-severity")
def get_debt_severity(
    user_id: int = Depends(get_current_user_id),
    db: Session = Depends(get_db),
):
    """
    GET /confessional/debt-severity
    Análisis de severidad: critical / warning / healthy
    """
    debt = get_or_create_debt(user_id, db)
    analysis = GeminiService.analyze_debt_severity(
        total_debt_minutes=debt.total_debt_minutes,
        free_time_minutes=debt.free_time_minutes,
    )
    return {
        **analysis,
        "total_debt_minutes": debt.total_debt_minutes,
        "free_time_minutes": debt.free_time_minutes,
        "ratio": debt.total_debt_minutes / max(debt.free_time_minutes, 1),
    }
