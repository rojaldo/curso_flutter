import 'package:flutter/material.dart';
import 'package:sample_app/ui/core/example_screen.dart';

/// Demuestra el efecto de `const` en la reconstrucción de widgets.
///
/// Muestra dos widgets: uno con const y otro sin const.
/// Un contador en el padre fuerza reconstrucciones.
/// Solo el widget SIN const se reconstruye innecesariamente.
class ConstWidgetExample extends StatefulWidget {
  const ConstWidgetExample({super.key});

  @override
  State<ConstWidgetExample> createState() => _ConstWidgetExampleState();
}

class _ConstWidgetExampleState extends State<ConstWidgetExample> {
  int _rebuildCount = 0;
  int _parentCounter = 0;

  @override
  Widget build(BuildContext context) {
    _rebuildCount++;
    const code = '''
// SIN const: se crea una nueva instancia cada vez
Text('Hola')  // ← Nuevo objeto cada rebuild

// CON const: se reutiliza la misma instancia
const Text('Hola')  // ← Mismo objeto, nunca se reconstruye

// ¿Cuándo usar const?
// ✅ Cuando el widget y TODOS sus parámetros son constantes
// ❌ Cuando el widget recibe datos variables (ej: contador)

class MiWidget extends StatelessWidget {
  const MiWidget({super.key});  // ← const constructor

  @override
  Widget build(BuildContext context) {
    return const Text('Siempre igual');  // ← const build
  }
}
''';

    return ExampleScreen(
      title: 'const y rendimiento',
      description: 'Cuando un padre llama setState(), todos sus hijos se '
          'reconstruyen. Pero si un hijo es const, Flutter lo reutiliza sin '
          'reconstruir. Observa cómo el widget const no incrementa su contador '
          'de builds, mientras el no-const sí.',
      code: code,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Reconstrucciones del padre: $_rebuildCount',
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          FilledButton.icon(
            onPressed: () => setState(() => _parentCounter++),
            icon: const Icon(Icons.add),
            label: Text('Reconstruir padre (setState) — contador: $_parentCounter'),
          ),
          const SizedBox(height: 16),
          // Sin const
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.red.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '❌ SIN const',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
                ),
                const Text(
                  'Se reconstruye en cada setState() del padre,\naunque su contenido no cambie.',
                  style: TextStyle(fontSize: 12),
                ),
                const SizedBox(height: 8),
                _NonConstLabel(label: 'Texto fijo sin const'),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Con const
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '✅ CON const',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
                ),
                const Text(
                  'Se reutiliza la misma instancia.\nNunca se reconstruye innecesariamente.',
                  style: TextStyle(fontSize: 12),
                ),
                const SizedBox(height: 8),
                const _ConstLabel(),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              '💡 Regla: usa const cuando el widget y TODOS sus '
              'parámetros son constantes en tiempo de compilación. '
              'Si recibe datos variables (ej: un contador), no puede ser const.',
              style: TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}

/// Widget SIN const — se reconstruye cada vez.
class _NonConstLabel extends StatefulWidget {
  // No es const constructor
  _NonConstLabel({required this.label});

  final String label;
  int _buildCount = 0;

  @override
  State<_NonConstLabel> createState() => _NonConstLabelState();
}

class _NonConstLabelState extends State<_NonConstLabel> {
  @override
  void initState() {
    super.initState();
    widget._buildCount = 0;
  }

  @override
  Widget build(BuildContext context) {
    widget._buildCount++;
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.red.shade100,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: [
          const Icon(Icons.refresh, size: 16, color: Colors.red),
          const SizedBox(width: 4),
          Text(widget.label),
          const Spacer(),
          Text('build: ${widget._buildCount}', style: const TextStyle(fontSize: 11, color: Colors.red)),
        ],
      ),
    );
  }
}

/// Widget CON const — nunca se reconstruye.
class _ConstLabel extends StatefulWidget {
  const _ConstLabel();

  @override
  State<_ConstLabel> createState() => _ConstLabelState();
}

class _ConstLabelState extends State<_ConstLabel> {
  int _buildCount = 0;

  @override
  Widget build(BuildContext context) {
    _buildCount++;
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.green.shade100,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle, size: 16, color: Colors.green),
          const SizedBox(width: 4),
          const Text('const Text("Texto fijo")'),
          const Spacer(),
          Text('build: $_buildCount', style: const TextStyle(fontSize: 11, color: Colors.green)),
        ],
      ),
    );
  }
}