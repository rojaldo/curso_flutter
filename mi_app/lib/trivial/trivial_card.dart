import 'package:flutter/material.dart';
import 'package:mi_app/model/trivial.dart';

/// Tarjeta individual para una pregunta Trivial.
/// Estética flat: fondo blanco, sin elevación, borde fino.
class TrivialCard extends StatelessWidget {
  final Trivial question;
  final int index;
  final bool Function(String answer) onAnswer;

  const TrivialCard({
    super.key,
    required this.question,
    required this.index,
    required this.onAnswer,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.black.withValues(alpha: 0.08)),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Header(category: question.category, difficulty: question.difficulty),
          const SizedBox(height: 12),
          Text(
            question.question,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          for (final answer in question.allAnswers)
            _AnswerTile(
              answer: answer,
              question: question,
              onAnswer: onAnswer,
            ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final String category;
  final String difficulty;
  const _Header({required this.category, required this.difficulty});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 4,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(
          category,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: Colors.black.withValues(alpha: 0.6),
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        _DifficultyChip(difficulty: difficulty),
      ],
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        difficulty.isEmpty ? '—' : difficulty,
        style: TextStyle(
          color: color.withValues(alpha: 0.9),
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _AnswerTile extends StatelessWidget {
  final String answer;
  final Trivial question;
  final bool Function(String answer) onAnswer;

  const _AnswerTile({
    required this.answer,
    required this.question,
    required this.onAnswer,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = question.selectedAnswer == answer;
    final isCorrect = question.isCorrect(answer);
    final answered = question.responded;

    Color? bg;
    Color fg = Colors.black87;
    IconData? icon;
    if (answered && isCorrect) {
      bg = Colors.green.shade50;
      fg = Colors.green.shade900;
      icon = Icons.check;
    } else if (answered && isSelected && !isCorrect) {
      bg = Colors.red.shade50;
      fg = Colors.red.shade900;
      icon = Icons.close;
    } else if (answered) {
      bg = Colors.black.withValues(alpha: 0.03);
    }

    final border = (isSelected && !answered)
        ? Theme.of(context).colorScheme.primary
        : Colors.black.withValues(alpha: 0.08);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Material(
        color: bg ?? Colors.transparent,
        borderRadius: BorderRadius.circular(6),
        child: InkWell(
          onTap: answered ? null : () => onAnswer(answer),
          borderRadius: BorderRadius.circular(6),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: border),
            ),
            child: Row(
              children: [
                if (icon != null) ...[
                  Icon(icon, color: fg, size: 16),
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
      ),
    );
  }
}