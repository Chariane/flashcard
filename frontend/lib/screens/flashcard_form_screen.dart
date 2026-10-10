import 'package:flutter/material.dart';

import '../models/flashcard.dart';

class FlashcardFormScreen extends StatefulWidget {
  final Flashcard? flashcard;

  const FlashcardFormScreen({super.key, this.flashcard});

  @override
  State<FlashcardFormScreen> createState() => _FlashcardFormScreenState();
}

class _FlashcardFormScreenState extends State<FlashcardFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController questionController;
  late final TextEditingController answerController;

  bool get isEditing => widget.flashcard != null;

  @override
  void initState() {
    super.initState();
    questionController = TextEditingController(
      text: widget.flashcard?.question ?? '',
    );
    answerController = TextEditingController(
      text: widget.flashcard?.answer ?? '',
    );
  }

  void saveFlashcard() {
    if (!_formKey.currentState!.validate()) return;

    Navigator.pop(
      context,
      Flashcard(
        id: widget.flashcard?.id ?? 0,
        question: questionController.text.trim(),
        answer: answerController.text.trim(),
      ),
    );
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
        title: Text(isEditing ? 'Modifier la carte' : 'Nouvelle carte'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: questionController,
                autofocus: true,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Question',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Saisis une question'
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: answerController,
                minLines: 2,
                maxLines: 5,
                decoration: const InputDecoration(
                  labelText: 'Réponse',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Saisis une réponse'
                    : null,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: saveFlashcard,
                  child: Text(isEditing ? 'Enregistrer' : 'Ajouter la carte'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
