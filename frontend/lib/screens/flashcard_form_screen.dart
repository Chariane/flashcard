import 'package:flutter/material.dart';

import '../models/flashcard.dart';
import '../theme/app_colors.dart';

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
        title: Text(isEditing ? 'Modifier une carte' : 'Nouvelle carte'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(22, 12, 22, 30),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 620),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 58,
                      height: 58,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.secondaryContainer,
                        borderRadius: BorderRadius.circular(19),
                      ),
                      child: Icon(
                        isEditing
                            ? Icons.edit_note_rounded
                            : Icons.add_card_rounded,
                        color: AppColors.primary,
                        size: 30,
                      ),
                    ),
                    const SizedBox(height: 22),
                    Text(
                      isEditing
                          ? 'Peaufine ta carte'
                          : 'Crée une nouvelle carte',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontSize: 27,
                        height: 1.2,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -.6,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      isEditing
                          ? 'Tu peux modifier la question ou sa réponse.'
                          : 'Une bonne question aide ta mémoire à faire le reste.',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 27),
                    const _FieldHeading(
                      number: '01',
                      title: 'Le recto',
                      subtitle: 'La question à te poser',
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: questionController,
                      autofocus: true,
                      textCapitalization: TextCapitalization.sentences,
                      textInputAction: TextInputAction.next,
                      minLines: 2,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        hintText: 'Ex. Quelle est la capitale du Bénin ?',
                        alignLabelWithHint: true,
                      ),
                      validator: (value) =>
                          value == null || value.trim().isEmpty
                          ? 'Saisis une question pour le recto.'
                          : null,
                    ),
                    const SizedBox(height: 24),
                    const _FieldHeading(
                      number: '02',
                      title: 'Le verso',
                      subtitle: 'La réponse à retenir',
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: answerController,
                      textCapitalization: TextCapitalization.sentences,
                      textInputAction: TextInputAction.done,
                      minLines: 2,
                      maxLines: 5,
                      decoration: const InputDecoration(
                        hintText: 'Ex. Porto-Novo',
                        alignLabelWithHint: true,
                      ),
                      validator: (value) =>
                          value == null || value.trim().isEmpty
                          ? 'Saisis une réponse pour le verso.'
                          : null,
                      onFieldSubmitted: (_) => saveFlashcard(),
                    ),
                    const SizedBox(height: 28),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: saveFlashcard,
                        icon: Icon(
                          isEditing ? Icons.check_rounded : Icons.add_rounded,
                        ),
                        label: Text(
                          isEditing
                              ? 'Enregistrer les changements'
                              : 'Ajouter à ma collection',
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Center(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Annuler'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FieldHeading extends StatelessWidget {
  final String number;
  final String title;
  final String subtitle;

  const _FieldHeading({
    required this.number,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 31,
          height: 31,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            number,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(width: 11),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              subtitle,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
