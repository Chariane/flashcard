from sqlalchemy.orm import Session
from app.models import Flashcard
from app.schemas import FlashcardCreate

def get_flashcards(db: Session):
    return db.query(Flashcard).all()


def get_flashcard(db: Session, flashcard_id: int):
    return (
        db.query(Flashcard)
        .filter(Flashcard.id == flashcard_id)
        .first()
    )


def create_flashcard(db: Session, flashcard: FlashcardCreate):
    new_flashcard = Flashcard(
        question=flashcard.question,
        answer=flashcard.answer
    )

    db.add(new_flashcard)
    db.commit()
    db.refresh(new_flashcard)

    return new_flashcard


def update_flashcard(
    db: Session,
    flashcard_id: int,
    flashcard: FlashcardCreate
):
    existing_flashcard = get_flashcard(db, flashcard_id)

    if existing_flashcard is None:
        return None

    existing_flashcard.question = flashcard.question
    existing_flashcard.answer = flashcard.answer

    db.commit()
    db.refresh(existing_flashcard)

    return existing_flashcard


def delete_flashcard(db: Session, flashcard_id: int):
    flashcard = get_flashcard(db, flashcard_id)

    if flashcard is None:
        return None

    db.delete(flashcard)
    db.commit()

    return flashcard