import 'package:flutter/material.dart';

import '../models/flashcard.dart';
import '../widgets/flashcard_widget.dart';
import 'flashcard_form_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Flashcard> flashcards = [
    const Flashcard(
      id: 1,
      question: 'Quelle est la capitale du Bénin ?',
      answer: 'Porto-Novo',
    ),
    const Flashcard(
      id: 2,
      question: 'Combien font 8 × 7 ?',
      answer: '56',
    ),
    const Flashcard(
      id: 3,
      question: 'Quelle planète est surnommée la planète rouge ?',
      answer: 'Mars',
    ),
  ];

  int currentIndex = 0;

  Future<void> openForm({Flashcard? flashcard}) async {
    final result = await Navigator.push<Flashcard>(
      context,
      MaterialPageRoute(
        builder: (context) => FlashcardFormScreen(flashcard: flashcard),
      ),
    );

    if (!mounted || result == null) return;

    setState(() {
      if (flashcard == null) {
        final nextId = flashcards.isEmpty
            ? 1
            : flashcards.map((card) => card.id).reduce((a, b) => a > b ? a : b) + 1;
        flashcards.add(
          Flashcard(id: nextId, question: result.question, answer: result.answer),
        );
        currentIndex = flashcards.length - 1;
      } else {
        final index = flashcards.indexWhere((card) => card.id == flashcard.id);
        if (index != -1) flashcards[index] = result;
      }
    });
  }

  void deleteCurrentFlashcard() {
    if (flashcards.isEmpty) return;
    setState(() {
      flashcards.removeAt(currentIndex);
      if (currentIndex >= flashcards.length && currentIndex > 0) {
        currentIndex--;
      }
    });
  }

  void showNext() {
    if (currentIndex < flashcards.length - 1) {
      setState(() => currentIndex++);
    }
  }

  void showPrevious() {
    if (currentIndex > 0) {
      setState(() => currentIndex--);
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasCards = flashcards.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Flashcards'),
        actions: [
          if (hasCards)
            IconButton(
              tooltip: 'Modifier cette carte',
              icon: const Icon(Icons.edit_outlined),
              onPressed: () => openForm(flashcard: flashcards[currentIndex]),
            ),
          if (hasCards)
            IconButton(
              tooltip: 'Supprimer cette carte',
              icon: const Icon(Icons.delete_outline),
              onPressed: deleteCurrentFlashcard,
            ),
        ],
      ),
      body: Center(
        child: hasCards
            ? Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FlashcardWidget(
                      key: ValueKey(flashcards[currentIndex].id),
                      flashcard: flashcards[currentIndex],
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        OutlinedButton.icon(
                          onPressed: currentIndex > 0 ? showPrevious : null,
                          icon: const Icon(Icons.arrow_back),
                          label: const Text('Précédente'),
                        ),
                        Text('${currentIndex + 1} / ${flashcards.length}'),
                        OutlinedButton.icon(
                          onPressed: currentIndex < flashcards.length - 1
                              ? showNext
                              : null,
                          icon: const Icon(Icons.arrow_forward),
                          label: const Text('Suivante'),
                        ),
                      ],
                    ),
                  ],
                ),
              )
            : const Padding(
                padding: EdgeInsets.all(32),
                child: Text(
                  'Aucune carte pour le moment. Appuie sur + pour en créer une.',
                  textAlign: TextAlign.center,
                ),
              ),
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Ajouter une carte',
        onPressed: () => openForm(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
