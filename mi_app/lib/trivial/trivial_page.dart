import 'package:flutter/material.dart';
import 'package:mi_app/model/trivial.dart';
import 'package:mi_app/trivial/trivial_card.dart';
import 'package:mi_app/trivial/trivial_provider.dart';
import 'package:provider/provider.dart';

class TrivialPage extends StatelessWidget {
  const TrivialPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TrivialProvider()..fetch(),
      child: const Scaffold(body: _TrivialBody()),
    );
  }
}

class _TrivialBody extends StatelessWidget {
  const _TrivialBody();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TrivialProvider>();
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          title: const Text('Trivial'),
          floating: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: 'Recargar',
              onPressed: provider.loading ? null : () => provider.fetch(),
            ),
          ],
        ),
        if (provider.loading)
          const SliverFillRemaining(
            child: Center(child: CircularProgressIndicator()),
          )
        else if (provider.error != null)
          SliverFillRemaining(
            child: Center(child: Text('Error: ${provider.error}')),
          )
        else ...[
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Aciertos: ${provider.score}/${provider.questions.length}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: _ResponsiveGrid(questions: provider.questions),
          ),
        ],
      ],
    );
  }
}

/// Grid responsive: 1 columna en móvil, hasta 3 en pantallas anchas.
/// ponytail: Wrap + width calculado evita SliverGrid con altura fija,
/// que cortaría las preguntas largas.
class _ResponsiveGrid extends StatelessWidget {
  final List<Trivial> questions;
  const _ResponsiveGrid({required this.questions});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = _columnsFor(constraints.maxWidth);
        const gap = 12.0;
        final cardWidth =
            (constraints.maxWidth - gap * (columns - 1)) / columns;
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          child: Wrap(
            spacing: gap,
            runSpacing: gap,
            children: [
              for (int i = 0; i < questions.length; i++)
                SizedBox(
                  width: cardWidth,
                  child: TrivialCard(
                    question: questions[i],
                    index: i,
                    selected: null,
                    onAnswer: (a) =>
                        context.read<TrivialProvider>().respond(i, a),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  int _columnsFor(double width) {
    if (width >= 1100) return 3;
    if (width >= 700) return 2;
    return 1;
  }
}