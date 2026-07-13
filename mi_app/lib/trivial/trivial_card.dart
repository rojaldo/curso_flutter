import 'package:flutter/material.dart';
import 'package:mi_app/model/trivial.dart';

/// Tarjeta individual para una pregunta Trivial.
///
/// ponytail: el color de estado (sin responder / correcta / incorrecta)
/// se calcula en una sola función para evitar ramas duplicadas en build.
class TrivialCard extends StatelessWidget {
  final Trivial question;
  final int index;
  final String? selected;
  final ValueChanged<String> onAnswer;

  const TrivialCard({
    super.key,
    required this.question,
    required this.index,
    required this.selected,
    required this.onAnswer,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    question.category,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                _DifficultyChip(difficulty: question.difficulty),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              question.question,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            for (final answer in question.allAnswers)
              _AnswerTile(
                answer: answer,
                selected: selected,
                question: question,
                onAnswer: onAnswer,
              ),
          ],
        ),
      ),
    );
  }
}

class _DifficultyChip extends StatelessWidget {
  final String difficulty;
  const _DifficultyChip({required this.difficulty});

  @override
  Widget build(BuildContext context) {
    final color = switch (difficulty) {
      'easy' => Colors.green,
      'medium' => Colors.orange,
      'hard' => Colors.red,
      _ => Colors.grey,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        difficulty.isEmpty ? '—' : difficulty,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _AnswerTile extends StatelessWidget {
  final String answer;
  final String? selected;
  final Trivial question;
  final ValueChanged<String> onAnswer;

  const _AnswerTile({
    required this.answer,
    required this.selected,
    required this.question,
    required this.onAnswer,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = selected == answer;
    final isCorrect = question.isCorrect(answer);
    final answered = question.responded;

    Color? bg;
    Color? fg;
    IconData? icon;
    if (answered && isCorrect) {
      bg = Colors.green.shade100;
      fg = Colors.green.shade900;
      icon = Icons.check_circle;
    } else if (answered && isSelected && !isCorrect) {
      bg = Colors.red.shade100;
      fg = Colors.red.shade900;
      icon = Icons.cancel;
    } else if (answered) {
      bg = Theme.of(context).colorScheme.surfaceContainerHighest;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: InkWell(
        onTap: answered ? null : () => onAnswer(answer),
        borderRadius: BorderRadius.circular(8),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: (isSelected && !answered)
                  ? Theme.of(context).colorScheme.primary
                  : Colors.black12,
            ),
          ),
          child: Row(
            children: [
              if (icon != null) ...[
                Icon(icon, color: fg, size: 18),
                const SizedBox(width: 8),
              ],
              Expanded(
                child: Text(
                  answer,
                  style: TextStyle(
                    color: fg,
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.normal,
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