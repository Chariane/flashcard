import 'package:flutter/material.dart';

import '../models/flashcard.dart';
import '../services/flashcard_service.dart';
import '../widgets/flashcard_widget.dart';
import 'flashcard_form_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FlashcardService service = FlashcardService();

  List<Flashcard> flashcards = [];

  int currentIndex = 0;

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadFlashcards();
  }

  Future<void> loadFlashcards() async {
    try {
      final data = await service.getFlashcards();

      setState(() {
        flashcards = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur : $e'),
          ),
        );
      }
    }
  }

  Future<void> deleteCurrentFlashcard() async {
    if (flashcards.isEmpty) {
      return;
    }

    final flashcard = flashcards[currentIndex];

    try {
      await service.deleteFlashcard(flashcard.id);

      setState(() {
        flashcards.removeAt(currentIndex);

        if (currentIndex >= flashcards.length) {
          currentIndex = flashcards.length - 1;
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur : $e'),
          ),
        );
      }
    }
  }

  Future<void> openForm({Flashcard? flashcard}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FlashcardFormScreen(
          flashcard: flashcard,
        ),
      ),
    );

    if (result == true) {
      await loadFlashcards();
    }
  }

  void nextFlashcard() {
    if (flashcards.isEmpty) {
      return;
    }

    if (currentIndex < flashcards.length - 1) {
      setState(() {
        currentIndex++;
      });
    }
  }

  void previousFlashcard() {
    if (flashcards.isEmpty) {
      return;
    }

    if (currentIndex > 0) {
      setState(() {
        currentIndex--;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flashcard Quiz'),
        actions: [
          if (flashcards.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                openForm(
                  flashcard: flashcards[currentIndex],
                );
              },
            ),
          if (flashcards.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: deleteCurrentFlashcard,
            ),
        ],
      ),

      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : flashcards.isEmpty
              ? const Center(
                  child: Text(
                    'Aucune flashcard disponible.',
                    style: TextStyle(fontSize: 18),
                  ),
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FlashcardWidget(
                      key: ValueKey(
                        flashcards[currentIndex].id,
                      ),
                      flashcard: flashcards[currentIndex],
                    ),

                    const SizedBox(height: 30),

                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: currentIndex > 0
                              ? previousFlashcard
                              : null,
                          child: const Text('Previous'),
                        ),

                        Text(
                          '${currentIndex + 1} / ${flashcards.length}',
                        ),

                        ElevatedButton(
                          onPressed:
                              currentIndex <
                                      flashcards.length - 1
                                  ? nextFlashcard
                                  : null,
                          child: const Text('Next'),
                        ),
                      ],
                    ),
                  ],
                ),

      floatingActionButton: FloatingActionButton(
        onPressed: () => openForm(),
        child: const Icon(Icons.add),
      ),
    );
  }
}