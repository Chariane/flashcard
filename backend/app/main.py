from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.routers import flashcards

app = FastAPI(
    title="Flashcard Quiz API",
    description="API pour gérer les flashcards",
    version="1.0.0"
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(flashcards.router)


@app.get("/")
def root():
    return {
        "message": "Bienvenue sur Flashcard Quiz API"
    }