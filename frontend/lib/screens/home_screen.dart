import 'package:flutter/material.dart';

import '../models/flashcard.dart';
import '../services/flashcard_storage.dart';
import '../theme/app_colors.dart';
import '../widgets/flashcard_widget.dart';
import 'flashcard_form_screen.dart';

class HomeScreen extends StatefulWidget {
  final bool isDark;
  final VoidCallback onThemeToggle;

  const HomeScreen({
    super.key,
    required this.isDark,
    required this.onThemeToggle,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FlashcardStorage _storage = FlashcardStorage();
  List<Flashcard> flashcards = [];
  bool _isLoading = true;
  String? _storageError;

  static final List<Flashcard> _starterCards = [
    const Flashcard(
      id: 1,
      question: 'Quelle est la capitale du Bénin ?',
      answer: 'Porto-Novo',
    ),
    const Flashcard(id: 2, question: 'Combien font 8 × 7 ?', answer: '56'),
    const Flashcard(
      id: 3,
      question: 'Quelle planète est surnommée la planète rouge ?',
      answer: 'Mars',
    ),
  ];

  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadFlashcards();
  }

  Future<void> _loadFlashcards() async {
    try {
      final savedCards = await _storage.load();
      final cards = savedCards ?? List<Flashcard>.of(_starterCards);
      var errorMessage = savedCards == null
          ? 'Impossible de sauvegarder les cartes de départ sur cet appareil.'
          : null;

      if (savedCards == null) {
        final saved = await _storage.save(cards);
        if (saved) errorMessage = null;
      }

      if (!mounted) return;
      setState(() {
        flashcards = cards;
        _storageError = errorMessage;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        flashcards = [];
        _storageError =
            'Les cartes enregistrées n’ont pas pu être lues. Réessaie de recharger l’application.';
        _isLoading = false;
      });
    }
  }

  Future<bool> _saveCards(List<Flashcard> cards) async {
    try {
      final saved = await _storage.save(cards);
      if (!mounted) return false;
      setState(
        () => _storageError = saved
            ? null
            : 'La sauvegarde locale a échoué. Vérifie l’espace disponible sur ton appareil.',
      );
      return saved;
    } catch (_) {
      if (mounted) {
        setState(
          () => _storageError =
              'La sauvegarde locale a échoué. Vérifie l’espace disponible sur ton appareil.',
        );
      }
      return false;
    }
  }

  void _showStorageError() {
    if (!mounted || _storageError == null) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(_storageError!),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  Future<void> openForm({Flashcard? flashcard}) async {
    final result = await Navigator.push<Flashcard>(
      context,
      MaterialPageRoute(
        builder: (context) => FlashcardFormScreen(flashcard: flashcard),
      ),
    );

    if (!mounted || result == null) return;

    final updatedCards = List<Flashcard>.of(flashcards);
    var updatedIndex = currentIndex;
    if (flashcard == null) {
      final nextId = updatedCards.isEmpty
          ? 1
          : updatedCards
                    .map((card) => card.id)
                    .reduce((a, b) => a > b ? a : b) +
                1;
      updatedCards.add(
        Flashcard(id: nextId, question: result.question, answer: result.answer),
      );
      updatedIndex = updatedCards.length - 1;
    } else {
      final index = updatedCards.indexWhere((card) => card.id == flashcard.id);
      if (index == -1) return;
      updatedCards[index] = result;
    }

    if (!await _saveCards(updatedCards)) {
      _showStorageError();
      return;
    }
    if (!mounted) return;
    setState(() {
      flashcards = updatedCards;
      currentIndex = updatedIndex;
    });

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            flashcard == null
                ? 'Carte ajoutée à ta collection !'
                : 'Carte mise à jour.',
          ),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      );
  }

  Future<void> deleteCurrentFlashcard() async {
    if (flashcards.isEmpty) return;
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer cette carte ?'),
        content: const Text(
          'Cette action supprimera définitivement la carte de cet appareil.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          FilledButton.tonal(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
    if (shouldDelete != true || !mounted) return;

    final updatedCards = List<Flashcard>.of(flashcards)..removeAt(currentIndex);
    if (!await _saveCards(updatedCards)) {
      _showStorageError();
      return;
    }
    if (!mounted) return;
    setState(() {
      flashcards = updatedCards;
      if (currentIndex >= flashcards.length && currentIndex > 0) currentIndex--;
    });
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: const Text('Carte supprimée.'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      );
  }

  void showNext() {
    if (currentIndex < flashcards.length - 1) setState(() => currentIndex++);
  }

  void showPrevious() {
    if (currentIndex > 0) setState(() => currentIndex--);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final hasCards = flashcards.isNotEmpty;
    final progress = hasCards ? (currentIndex + 1) / flashcards.length : 0.0;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(22, 18, 22, 28),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 760),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _TopBar(
                    cardCount: flashcards.length,
                    isDark: widget.isDark,
                    onThemeToggle: widget.onThemeToggle,
                  ),
                  if (_storageError != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.tertiaryContainer,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text(
                        _storageError!,
                        style: TextStyle(
                          color: Theme.of(
                            context,
                          ).colorScheme.onTertiaryContainer,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 38),
                  Text(
                    hasCards ? 'À toi de jouer ✨' : 'On commence ? ✨',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontSize: 32,
                      height: 1.15,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    hasCards
                        ? 'Une question à la fois. Le progrès suit.'
                        : 'Crée ta première carte et lance ta révision.',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 26),
                  if (hasCards) ...[
                    Row(
                      children: [
                        Text(
                          'TA SESSION',
                          style: TextStyle(
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurfaceVariant,
                            fontSize: 10,
                            letterSpacing: 1.4,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          'Carte ${currentIndex + 1} sur ${flashcards.length}',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 6,
                        backgroundColor: Theme.of(
                          context,
                        ).colorScheme.surfaceContainerHighest,
                        valueColor: const AlwaysStoppedAnimation(
                          AppColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    FlashcardWidget(
                      key: ValueKey(flashcards[currentIndex].id),
                      flashcard: flashcards[currentIndex],
                      onEdit: () =>
                          openForm(flashcard: flashcards[currentIndex]),
                      onDelete: deleteCurrentFlashcard,
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        _NavigationButton(
                          tooltip: 'Carte précédente',
                          icon: Icons.arrow_back_rounded,
                          onPressed: currentIndex > 0 ? showPrevious : null,
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).colorScheme.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(
                              color: Theme.of(
                                context,
                              ).colorScheme.outlineVariant,
                            ),
                          ),
                          child: Text(
                            '${currentIndex + 1}  /  ${flashcards.length}',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface,
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        const Spacer(),
                        _NavigationButton(
                          tooltip: 'Carte suivante',
                          icon: Icons.arrow_forward_rounded,
                          onPressed: currentIndex < flashcards.length - 1
                              ? showNext
                              : null,
                        ),
                      ],
                    ),
                  ] else
                    _EmptyState(onAdd: () => openForm()),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () => openForm(),
                      icon: const Icon(Icons.add_rounded),
                      label: const Text('Créer une carte'),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 17),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Center(
                    child: Text(
                      'Tes cartes sont enregistrées sur cet appareil.',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  final int cardCount;
  final bool isDark;
  final VoidCallback onThemeToggle;

  const _TopBar({
    required this.cardCount,
    required this.isDark,
    required this.onThemeToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: const LinearGradient(
              colors: [Color(0xFF776BE0), Color(0xFF5145A7)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: const Icon(
            Icons.auto_stories_rounded,
            color: Colors.white,
            size: 23,
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Mémoria',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              'STUDIO DE RÉVISION',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontSize: 9,
                letterSpacing: 1.15,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.secondaryContainer,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Row(
            children: [
              Icon(
                Icons.layers_rounded,
                color: Theme.of(context).colorScheme.onSecondaryContainer,
                size: 15,
              ),
              const SizedBox(width: 6),
              Text(
                '$cardCount cartes',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSecondaryContainer,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 4),
        IconButton(
          tooltip: isDark ? 'Activer le mode clair' : 'Activer le mode sombre',
          onPressed: onThemeToggle,
          icon: Icon(
            isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
          ),
          style: IconButton.styleFrom(
            foregroundColor: Theme.of(context).colorScheme.onSurfaceVariant,
            minimumSize: const Size(42, 42),
          ),
        ),
      ],
    );
  }
}

class _NavigationButton extends StatelessWidget {
  final String tooltip;
  final IconData icon;
  final VoidCallback? onPressed;

  const _NavigationButton({
    required this.tooltip,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton.filledTonal(
      tooltip: tooltip,
      onPressed: onPressed,
      icon: Icon(icon),
      style: IconButton.styleFrom(
        foregroundColor: Theme.of(context).colorScheme.onSecondaryContainer,
        backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
        disabledForegroundColor: Theme.of(
          context,
        ).colorScheme.onSurface.withValues(alpha: .35),
        disabledBackgroundColor: Theme.of(context).colorScheme.surfaceContainer,
        minimumSize: const Size(48, 48),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onAdd;

  const _EmptyState({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 42),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Column(
        children: [
          Container(
            width: 78,
            height: 78,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondaryContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.style_rounded,
              color: Theme.of(context).colorScheme.onSecondaryContainer,
              size: 34,
            ),
          ),
          const SizedBox(height: 18),
          Text(
            'Ta collection est vide',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 19,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            'Ajoute une question et sa réponse pour commencer à réviser.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 19),
          TextButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add_rounded),
            label: const Text('Ajouter ma première carte'),
          ),
        ],
      ),
    );
  }
}
