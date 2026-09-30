from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from app import crud, schemas
from app.database import get_db

router = APIRouter(
    prefix="/flashcards",
    tags=["Flashcards"]
)


@router.get("/", response_model=list[schemas.FlashcardResponse])
def get_flashcards(db: Session = Depends(get_db)):
    return crud.get_flashcards(db)


@router.get("/{flashcard_id}", response_model=schemas.FlashcardResponse)
def get_flashcard(
    flashcard_id: int,
    db: Session = Depends(get_db)
):
    flashcard = crud.get_flashcard(db, flashcard_id)

    if flashcard is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Flashcard introuvable"
        )

    return flashcard


@router.post(
    "/",
    response_model=schemas.FlashcardResponse,
    status_code=status.HTTP_201_CREATED
)
def create_flashcard(
    flashcard: schemas.FlashcardCreate,
    db: Session = Depends(get_db)
):
    return crud.create_flashcard(db, flashcard)


@router.put(
    "/{flashcard_id}",
    response_model=schemas.FlashcardResponse
)
def update_flashcard(
    flashcard_id: int,
    flashcard: schemas.FlashcardCreate,
    db: Session = Depends(get_db)
):
    updated_flashcard = crud.update_flashcard(
        db,
        flashcard_id,
        flashcard
    )

    if updated_flashcard is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Flashcard introuvable"
        )

    return updated_flashcard


@router.delete("/{flashcard_id}")
def delete_flashcard(
    flashcard_id: int,
    db: Session = Depends(get_db)
):
    deleted_flashcard = crud.delete_flashcard(
        db,
        flashcard_id
    )

    if deleted_flashcard is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Flashcard introuvable"
        )

    return {
        "message": "Flashcard supprimée avec succès"
    }