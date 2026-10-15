import 'package:flutter/material.dart';

import '../models/flashcard.dart';
import '../theme/app_colors.dart';

class FlashcardWidget extends StatefulWidget {
  final Flashcard flashcard;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const FlashcardWidget({
    super.key,
    required this.flashcard,
    this.onEdit,
    this.onDelete,
  });

  @override
  State<FlashcardWidget> createState() => _FlashcardWidgetState();
}

class _FlashcardWidgetState extends State<FlashcardWidget> {
  bool showAnswer = false;

  void toggleAnswer() => setState(() => showAnswer = !showAnswer);

  @override
  Widget build(BuildContext context) {
    final title = showAnswer ? 'RÉPONSE' : 'QUESTION';
    final content = showAnswer
        ? widget.flashcard.answer
        : widget.flashcard.question;
    final icon = showAnswer
        ? Icons.auto_awesome_rounded
        : Icons.lightbulb_outline_rounded;

    return Container(
      height: 360,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF29264F), Color(0xFF5145A7), Color(0xFF776BE0)],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: .22),
            blurRadius: 35,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: Stack(
          children: [
            Positioned(
              right: -62,
              top: -85,
              child: Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: .055),
                ),
              ),
            ),
            Positioned(
              left: -80,
              bottom: -120,
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFB9F0D2).withValues(alpha: .08),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(22),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: .12),
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: .12),
                          ),
                        ),
                        child: Text(
                          title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            letterSpacing: 1.5,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      const Spacer(),
                      if (widget.onEdit != null)
                        _CardAction(
                          tooltip: 'Modifier la carte',
                          icon: Icons.edit_rounded,
                          onPressed: widget.onEdit!,
                        ),
                      if (widget.onDelete != null) ...[
                        const SizedBox(width: 8),
                        _CardAction(
                          tooltip: 'Supprimer la carte',
                          icon: Icons.delete_outline_rounded,
                          onPressed: widget.onDelete!,
                        ),
                      ],
                    ],
                  ),
                  Expanded(
                    child: Center(
                      child: SingleChildScrollView(
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 260),
                          switchInCurve: Curves.easeOutBack,
                          switchOutCurve: Curves.easeIn,
                          transitionBuilder: (child, animation) =>
                              FadeTransition(
                                opacity: animation,
                                child: ScaleTransition(
                                  scale: animation,
                                  child: child,
                                ),
                              ),
                          child: Column(
                            key: ValueKey(showAnswer),
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 58,
                                height: 58,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white.withValues(alpha: .13),
                                ),
                                child: Icon(
                                  icon,
                                  color: const Color(0xFFC9F3A6),
                                  size: 27,
                                ),
                              ),
                              const SizedBox(height: 22),
                              Text(
                                content,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: showAnswer ? 30 : 26,
                                  height: 1.3,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 48,
                    child: OutlinedButton.icon(
                      onPressed: toggleAnswer,
                      icon: Icon(
                        showAnswer
                            ? Icons.refresh_rounded
                            : Icons.visibility_rounded,
                        size: 18,
                      ),
                      label: Text(
                        showAnswer
                            ? 'Revoir la question'
                            : 'Afficher la réponse',
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: BorderSide(
                          color: Colors.white.withValues(alpha: .42),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        textStyle: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CardAction extends StatelessWidget {
  final String tooltip;
  final IconData icon;
  final VoidCallback onPressed;

  const _CardAction({
    required this.tooltip,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: tooltip,
      onPressed: onPressed,
      icon: Icon(icon, size: 19),
      style: IconButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: Colors.white.withValues(alpha: .12),
        minimumSize: const Size(40, 40),
        maximumSize: const Size(40, 40),
      ),
    );
  }
}
