import logging
from typing import List

from fastapi import APIRouter, HTTPException
from pydantic import BaseModel, Field

from app.core.config import settings
from app.services.gemini_service import GeminiOptimizer

logger = logging.getLogger(__name__)

router = APIRouter()


class TaskRequest(BaseModel):
    title: str
    priority: int = Field(..., ge=1, le=3)
    energy: int = Field(..., ge=1, le=5)


class TaskOptimizeRequest(BaseModel):
    tasks: List[TaskRequest]


class TaskOptimizeResponse(BaseModel):
    optimized: List[TaskRequest]
    explanation: str


@router.post("/optimize", response_model=TaskOptimizeResponse)
async def optimize(payload: TaskOptimizeRequest) -> TaskOptimizeResponse:
    logger.info("POST /optimize received with %d tasks", len(payload.tasks))

    if not settings.gemini_api_key:
        logger.error("gemini_api_key is not configured")
        raise HTTPException(status_code=503, detail="Gemini API key not configured")

    optimizer = GeminiOptimizer(api_key=settings.gemini_api_key)
    tasks_dict = [t.model_dump() for t in payload.tasks]

    try:
        result = await optimizer.optimize_tasks(tasks_dict)
    except Exception as exc:
        logger.exception("Unexpected failure calling GeminiOptimizer: %s", exc)
        raise HTTPException(status_code=503, detail="Gemini service unavailable") from exc

    if "optimized" not in result or "explanation" not in result:
        logger.error("Malformed optimizer result: %s", result)
        raise HTTPException(status_code=503, detail="Malformed optimizer response")

    logger.info("POST /optimize succeeded")
    return TaskOptimizeResponse(
        optimized=[TaskRequest(**t) for t in result["optimized"]],
        explanation=result["explanation"],
    )
