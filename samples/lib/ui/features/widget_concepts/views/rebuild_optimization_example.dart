import 'package:flutter/material.dart';
import 'package:sample_app/ui/core/example_screen.dart';

/// Demuestra el principio de que setState marca el widget como sucio
/// y Flutter reconstruye solo los widgets afectados.
class RebuildOptimizationExample extends StatefulWidget {
  const RebuildOptimizationExample({super.key});

  @override
  State<RebuildOptimizationExample> createState() =>
      _RebuildOptimizationExampleState();
}

class _RebuildOptimizationExampleState
    extends State<RebuildOptimizationExample> {
  int _counter = 0;
  int _parentBuilds = 0;
  int _badChildBuilds = 0;
  int _goodChildBuilds = 0;
  int _valueNotifierBuilds = 0;

  final ValueNotifier<int> _optimizedCounter = ValueNotifier(0);

  @override
  void dispose() {
    _optimizedCounter.dispose();
    super.dispose();
  }

  void _increment() {
    setState(() {
      _counter++;
      _optimizedCounter.value++;
    });
  }

  @override
  Widget build(BuildContext context) {
    _parentBuilds++;
    _badChildBuilds++;
    _goodChildBuilds++;
    _valueNotifierBuilds++;

    const code = '''
// ❌ PROBLEMA: setState reconstruye todo el subárbol
class _MyState extends State<MyWidget> {
  int _counter = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('Contador: \$_counter'),  // ← Se reconstruye
        VeryExpensiveWidget(),           // ← TAMBIÉN se reconstruye 😱
      ],
    );
  }
}

// ✅ SOLUCIÓN 1: Extraer a StatelessWidget con const
// Si VeryExpensiveWidget no usa _counter,
// extraerlo como const evita reconstrucciones.
const VeryExpensiveWidget()  // ← Nunca se reconstruye

// ✅ SOLUCIÓN 2: ValueNotifier + ValueListenableBuilder
// Solo reconstruye el widget que escucha.
ValueNotifier<int> _counter = ValueNotifier(0);

ValueListenableBuilder<int>(
  valueListenable: _counter,
  builder: (context, value, child) {
    return Text('\$value');  // ← Solo esto se reconstruye
  },
)
''';

    return ExampleScreen(
      title: 'Optimización de reconstrucciones',
      description: 'setState() marca todo el widget como sucio y reconstruye '
          'todo su subárbol. Pero a menudo solo un pequeño fragmento necesita '
          'actualizarse. Aquí se muestran tres estrategias para optimizar.',
      code: code,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FilledButton.icon(
            onPressed: _increment,
            icon: const Icon(Icons.add),
            label: const Text('Incrementar ambos contadores'),
          ),
          const SizedBox(height: 16),
          // Sin optimización
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
                const Text('❌ Sin optimización',
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
                const Text('Todo el subárbol se reconstruye con setState()',
                    style: TextStyle(fontSize: 12)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Text('Contador: ', style: TextStyle(fontSize: 20)),
                    Text('$_counter', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  ],
                ),
                Container(
                  margin: const EdgeInsets.only(top: 4),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.red.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text('Parent builds: $_parentBuilds | Child builds: $_badChildBuilds',
                      style: const TextStyle(fontSize: 11)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Con const
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.orange.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('⚠️ Con const en widget estático',
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange)),
                const Text('El widget const no se reconstruye nunca',
                    style: TextStyle(fontSize: 12)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Text('Contador: ', style: TextStyle(fontSize: 20)),
                    Text('$_counter', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  ],
                ),
                const _StaticWidget(),
                Container(
                  margin: const EdgeInsets.only(top: 4),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text('Parent builds: $_parentBuilds | Child builds: $_goodChildBuilds | Static: 1',
                      style: const TextStyle(fontSize: 11)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // ValueNotifier
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
                const Text('✅ ValueNotifier + ValueListenableBuilder',
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                const Text('Solo se reconstruye el widget que escucha',
                    style: TextStyle(fontSize: 12)),
                const SizedBox(height: 8),
                ValueListenableBuilder<int>(
                  valueListenable: _optimizedCounter,
                  builder: (context, value, child) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Text('Contador: ', style: TextStyle(fontSize: 20)),
                            Text('$value', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        child!,
                      ],
                    );
                  },
                  child: const _StaticWidget(),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 4),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text('VLB builds: $_valueNotifierBuilds | Static widget: 1 build (const)',
                      style: const TextStyle(fontSize: 11)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StaticWidget extends StatelessWidget {
  const _StaticWidget();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      margin: const EdgeInsets.only(top: 4),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(4),
      ),
      child: const Row(
        children: [
          Icon(Icons.check_circle, size: 16, color: Colors.green),
          SizedBox(width: 4),
          Text('Widget estático (const) — nunca se reconstruye', style: TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}