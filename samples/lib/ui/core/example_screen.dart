import 'package:flutter/material.dart';
import 'package:sample_app/ui/core/code_dialog.dart';

/// Pantalla base reutilizable para cada ejemplo didáctico.
///
/// Proporciona un [Scaffold] con AppBar, descripción, zona de demo
/// y un botón para ver el código fuente.
class ExampleScreen extends StatelessWidget {
  const ExampleScreen({
    super.key,
    required this.title,
    required this.description,
    required this.code,
    required this.child,
  });

  final String title;
  final String description;
  final String code;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              description,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: child,
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () => CodeDialog.show(context, title, code),
              icon: const Icon(Icons.code),
              label: const Text('Ver código'),
            ),
          ],
        ),
      ),
    );
  }
}