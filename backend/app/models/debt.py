from sqlalchemy import Column, DateTime, Integer, Text, func

from app.models import Base


class ProductivityDebt(Base):
    __tablename__ = "productivity_debt"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, unique=True, nullable=False, index=True)
    total_debt_minutes = Column(Integer, default=0, nullable=False)
    free_time_minutes = Column(Integer, default=0, nullable=False)
    last_updated = Column(DateTime, default=func.now(), nullable=False)
    notes = Column(Text, nullable=True)
