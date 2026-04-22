from sqlalchemy import Column, Integer, String, DateTime, func

from app.models import Base


class User(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, index=True)
    email = Column(String(255), unique=True, index=True, nullable=False)
    username = Column(String(30), unique=True, index=True, nullable=False)
    hashed_password = Column(String(255), nullable=False)
    created_at = Column(DateTime, default=func.now(), nullable=False)

    def __repr__(self) -> str:
        return f"<User id={self.id} email={self.email!r} username={self.username!r}>"
