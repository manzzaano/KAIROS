from sqlalchemy import Column, DateTime, Float, Index, Integer, String, Boolean, func

from app.models import Base


class Task(Base):
    __tablename__ = "tasks"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, nullable=False, index=True)
    title = Column(String(255), nullable=False)
    priority = Column(Integer, nullable=False, default=1)
    energy = Column(Integer, nullable=False, default=3)
    estimated_minutes = Column(Integer, nullable=False, default=0)
    completed = Column(Boolean, default=False, nullable=False)
    completed_at = Column(DateTime, nullable=True)
    created_at = Column(DateTime, default=func.now(), nullable=False)
    abandoned = Column(Boolean, default=False, nullable=False)
    abandoned_at = Column(DateTime, nullable=True)
    latitude = Column(Float, nullable=True)
    longitude = Column(Float, nullable=True)

    __table_args__ = (
        Index("ix_tasks_user_created", "user_id", "created_at"),
        Index("ix_tasks_completed_at", "completed_at"),
    )
