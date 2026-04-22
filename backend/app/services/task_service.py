import logging
from datetime import datetime, timedelta

from sqlalchemy.orm import Session

from app.models.debt import ProductivityDebt
from app.models.task import Task

logger = logging.getLogger(__name__)


def get_or_create_debt(user_id: int, db: Session) -> ProductivityDebt:
    debt = db.query(ProductivityDebt).filter(ProductivityDebt.user_id == user_id).first()
    if not debt:
        debt = ProductivityDebt(user_id=user_id)
        db.add(debt)
        db.commit()
        db.refresh(debt)
    return debt


def calculate_streak_days(user_id: int, db: Session) -> int:
    """Count consecutive days going backward with completed tasks and no abandons."""
    today = datetime.utcnow().date()
    streak = 0

    for delta in range(365):
        day = today - timedelta(days=delta)
        day_start = datetime(day.year, day.month, day.day, 0, 0, 0)
        day_end = datetime(day.year, day.month, day.day, 23, 59, 59)

        abandoned_count = (
            db.query(Task)
            .filter(
                Task.user_id == user_id,
                Task.abandoned.is_(True),
                Task.abandoned_at >= day_start,
                Task.abandoned_at <= day_end,
            )
            .count()
        )
        if abandoned_count > 0:
            break

        completed_count = (
            db.query(Task)
            .filter(
                Task.user_id == user_id,
                Task.completed.is_(True),
                Task.completed_at >= day_start,
                Task.completed_at <= day_end,
            )
            .count()
        )
        if completed_count > 0:
            streak += 1
        elif delta > 0:
            break

    return streak


def update_debt_on_complete(user_id: int, estimated_minutes: int, db: Session) -> ProductivityDebt:
    debt = get_or_create_debt(user_id, db)
    debt.free_time_minutes += estimated_minutes
    debt.last_updated = datetime.utcnow()
    db.commit()
    db.refresh(debt)
    return debt


def update_debt_on_abandon(user_id: int, estimated_minutes: int, db: Session) -> ProductivityDebt:
    debt = get_or_create_debt(user_id, db)
    debt.total_debt_minutes += int(estimated_minutes * 1.5)
    debt.last_updated = datetime.utcnow()
    db.commit()
    db.refresh(debt)
    return debt
