import 'package:flutter/material.dart';
import 'package:sample_app/ui/core/example_screen.dart';

/// Ejemplo didáctico de navegación con Navigator.
///
/// Demuestra cómo abrir una pantalla, pasar argumentos y recibir
/// un resultado al cerrarla.
class NavigationExample extends StatefulWidget {
  const NavigationExample({super.key});

  @override
  State<NavigationExample> createState() => _NavigationExampleState();
}

class _NavigationExampleState extends State<NavigationExample> {
  String _lastResult = 'Ninguno';

  final String code = '''
// Abrir una ruta y pasar argumentos
final result = await Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => DetailPage(message: 'Hola'),
  ),
);

// En la pantalla destino, devolver un valor
Navigator.pop(context, 'Éxito');
'''; // ignore: unreachable_from_main

  @override
  Widget build(BuildContext context) {
    return ExampleScreen(
      title: 'Navigator',
      description:
          'Demostración de navegación entre pantallas, paso de argumentos '
          'y recepción de resultados al volver.',
      code: code,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Último resultado recibido:',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            _lastResult,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _openDetail,
            icon: const Icon(Icons.open_in_new),
            label: const Text('Abrir pantalla con argumento'),
          ),
        ],
      ),
    );
  }

  Future<void> _openDetail() async {
    final result = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (context) => const _DetailPage(message: '¡Hola desde Navigator!'),
      ),
    );

    if (mounted) {
      setState(() {
        _lastResult = result ?? 'Cancelado';
      });
    }
  }
}

/// Pantalla de destino para demostrar el paso de argumentos
/// y el retorno de resultados.
class _DetailPage extends StatelessWidget {
  const _DetailPage({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pantalla destino')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Argumento recibido:',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: () => Navigator.pop(context, 'Éxito'),
              icon: const Icon(Icons.check),
              label: const Text('Volver con resultado'),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.close),
              label: const Text('Volver sin resultado'),
            ),
          ],
        ),
      ),
    );
  }
}
