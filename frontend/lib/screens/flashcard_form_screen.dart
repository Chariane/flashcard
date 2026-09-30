import 'package:flutter/material.dart';

import '../models/flashcard.dart';
import '../services/flashcard_service.dart';

class FlashcardFormScreen extends StatefulWidget {
  final Flashcard? flashcard;

  const FlashcardFormScreen({
    super.key,
    this.flashcard,
  });

  @override
  State<FlashcardFormScreen> createState() =>
      _FlashcardFormScreenState();
}

class _FlashcardFormScreenState
    extends State<FlashcardFormScreen> {
  final _formKey = GlobalKey<FormState>();

  final questionController = TextEditingController();
  final answerController = TextEditingController();

  final FlashcardService service = FlashcardService();

  bool isLoading = false;

  bool get isEditing => widget.flashcard != null;

  @override
  void initState() {
    super.initState();

    if (isEditing) {
      questionController.text = widget.flashcard!.question;
      answerController.text = widget.flashcard!.answer;
    }
  }

  Future<void> saveFlashcard() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      if (isEditing) {
        await service.updateFlashcard(
          widget.flashcard!.id,
          questionController.text,
          answerController.text,
        );
      } else {
        await service.createFlashcard(
          questionController.text,
          answerController.text,
        );
      }

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur : $e'),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    questionController.dispose();
    answerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEditing
              ? 'Modifier la flashcard'
              : 'Ajouter une flashcard',
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: questionController,
                decoration: const InputDecoration(
                  labelText: 'Question',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Veuillez saisir une question';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 20),

              TextFormField(
                controller: answerController,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Réponse',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Veuillez saisir une réponse';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isLoading ? null : saveFlashcard,
                  child: isLoading
                      ? const CircularProgressIndicator()
                      : Text(
                          isEditing
                              ? 'Modifier'
                              : 'Ajouter',
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}