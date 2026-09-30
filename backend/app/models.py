from sqlalchemy import Column, Integer, Text
from app.database import Base


class Flashcard(Base):
    __tablename__ = "flashcard"

    id = Column(Integer, primary_key=True, index=True)
    question = Column(Text, nullable=False)
    answer = Column(Text, nullable=False)