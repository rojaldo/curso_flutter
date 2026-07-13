import 'package:flutter/material.dart';
import 'package:sample_app/ui/core/example_screen.dart';

/// Demuestra la diferencia entre StatelessWidget y StatefulWidget.
///
/// Muestra dos widgets lado a lado: uno stateless que recibe datos del padre,
/// y uno stateful que gestiona su propio estado interno. Un contador interactivo
/// permite observar cuándo se reconstruye cada uno.
class StatelessVsStatefulExample extends StatelessWidget {
  const StatelessVsStatefulExample({super.key});

  @override
  Widget build(BuildContext context) {
    const code = '''
// StatelessWidget: no tiene estado propio.
// Se reconstruye completamente cuando el padre cambia.
class MiWidget extends StatelessWidget {
  final int contador;  // Datos que vienen del padre
  const MiWidget({required this.contador});

  @override
  Widget build(BuildContext context) {
    return Text('Contador: \$contador');
  }
}

// StatefulWidget: tiene estado interno que persiste.
// Solo el State se reconstruye con setState().
class ContadorWidget extends StatefulWidget {
  const ContadorWidget();

  @override
  State<ContadorWidget> createState() => _ContadorWidgetState();
}

class _ContadorWidgetState extends State<ContadorWidget> {
  int _contador = 0;  // Estado interno

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () => setState(() => _contador++),
      child: Text('Contador: \$_contador'),
    );
  }
}
''';

    return ExampleScreen(
      title: 'StatelessWidget vs StatefulWidget',
      description: 'Un StatelessWidget no tiene estado propio: recibe datos '
          'del padre y se reconstruye cuando esos datos cambian. Un '
          'StatefulWidget tiene un objeto State separado que persiste y '
          'gestiona su propio estado con setState(). Toca los botones para ver '
          'cuándo se reconstruye cada uno.',
      code: code,
      child: const _StatelessVsStatefulDemo(),
    );
  }
}

class _StatelessVsStatefulDemo extends StatefulWidget {
  const _StatelessVsStatefulDemo();

  @override
  State<_StatelessVsStatefulDemo> createState() =>
      _StatelessVsStatefulDemoState();
}

class _StatelessVsStatefulDemoState extends State<_StatelessVsStatefulDemo> {
  int _parentCounter = 0;
  int _statelessRebuilds = 0;
  int _statefulRebuilds = 0;

  @override
  Widget build(BuildContext context) {
    _statelessRebuilds++;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Botón del padre que reconstruye todo
        FilledButton.icon(
          onPressed: () => setState(() => _parentCounter++),
          icon: const Icon(Icons.refresh),
          label: const Text('Reconstruir desde el padre (setState)'),
        ),
        Text(
          'Contador del padre: $_parentCounter',
          style: Theme.of(context).textTheme.titleMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        // Lado a lado
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // StatelessWidget
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Column(
                  children: [
                    const Text(
                      'StatelessWidget',
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Recibe datos del padre.\nSe reconstruye cada vez\nque el padre llama setState().',
                      style: TextStyle(fontSize: 12),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    _StatelessCounter(
                      value: _parentCounter,
                      rebuilds: _statelessRebuilds,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            // StatefulWidget
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Column(
                  children: [
                    const Text(
                      'StatefulWidget',
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Gestiona su propio estado.\nsetState() solo reconstruye\nsu método build().',
                      style: TextStyle(fontSize: 12),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    _StatefulCounter(rebuildsParent: () {
                      setState(() => _statefulRebuilds++);
                    }),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// StatelessWidget que muestra un valor recibido del padre.
class _StatelessCounter extends StatelessWidget {
  const _StatelessCounter({required this.value, required this.rebuilds});

  final int value;
  final int rebuilds;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          '$value',
          style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.blue.shade100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            'Reconstruido: $rebuilds veces',
            style: const TextStyle(fontSize: 11),
          ),
        ),
      ],
    );
  }
}

/// StatefulWidget con su propio contador interno.
class _StatefulCounter extends StatefulWidget {
  const _StatefulCounter({required this.rebuildsParent});

  final VoidCallback rebuildsParent;

  @override
  State<_StatefulCounter> createState() => _StatefulCounterState();
}

class _StatefulCounterState extends State<_StatefulCounter> {
  int _counter = 0;
  int _localRebuilds = 1;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          '$_counter',
          style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.green.shade100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            'Reconstruido: $_localRebuilds veces',
            style: const TextStyle(fontSize: 11),
          ),
        ),
        const SizedBox(height: 8),
        ElevatedButton(
          onPressed: () {
            setState(() {
              _counter++;
              _localRebuilds++;
            });
            widget.rebuildsParent();
          },
          child: const Text('+1 (interno)'),
        ),
      ],
    );
  }
}