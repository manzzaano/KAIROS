from datetime import datetime
from typing import List, Optional

from pydantic import BaseModel, Field


class TaskCreate(BaseModel):
    title: str = Field(..., min_length=1, max_length=255)
    priority: int = Field(..., ge=1, le=3)
    energy: int = Field(..., ge=1, le=5)
    estimated_minutes: int = Field(..., gt=0)
    latitude: Optional[float] = None
    longitude: Optional[float] = None


class TaskResponse(BaseModel):
    id: int
    title: str
    priority: int
    energy: int
    estimated_minutes: int
    completed: bool
    abandoned: bool
    created_at: datetime
    completed_at: Optional[datetime] = None
    abandoned_at: Optional[datetime] = None
    latitude: Optional[float] = None
    longitude: Optional[float] = None

    model_config = {"from_attributes": True}


class TaskListResponse(BaseModel):
    tasks: List[TaskResponse]
    total_tasks: int
    completed: int
    abandoned: int


class ProductivityDebtResponse(BaseModel):
    total_debt_minutes: int
    free_time_minutes: int
    last_updated: datetime
    streak_days: int


class PayDebtRequest(BaseModel):
    minutes_paid: int = Field(..., gt=0)
