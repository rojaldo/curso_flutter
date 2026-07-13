import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sample_app/ui/core/example_screen.dart';

/// Ejemplo didáctico de ValueNotifier y ValueListenableBuilder.
///
/// Muestra que solo el widget envuelto en ValueListenableBuilder
/// se reconstruye, mientras que el resto del árbol permanece estable.
class ValueNotifierExample extends StatefulWidget {
  const ValueNotifierExample({super.key});

  @override
  State<ValueNotifierExample> createState() => _ValueNotifierExampleState();
}

class _ValueNotifierExampleState extends State<ValueNotifierExample> {
  final ValueNotifier<int> _counter = ValueNotifier<int>(0);
  final ValueNotifier<Duration> _elapsed = ValueNotifier<Duration>(Duration.zero);
  final ValueNotifier<bool> _isRunning = ValueNotifier<bool>(false);
  Timer? _timer;

  int _wholeWidgetRebuilds = 0;

  void _increment() => _counter.value++;
  void _decrement() => _counter.value--;

  void _toggleTimer() {
    if (_isRunning.value) {
      _timer?.cancel();
      _isRunning.value = false;
    } else {
      _isRunning.value = true;
      final start = DateTime.now().subtract(_elapsed.value);
      _timer = Timer.periodic(const Duration(milliseconds: 100), (_) {
        _elapsed.value = DateTime.now().difference(start);
      });
    }
  }

  void _resetTimer() {
    _timer?.cancel();
    _isRunning.value = false;
    _elapsed.value = Duration.zero;
  }

  @override
  void dispose() {
    _counter.dispose();
    _elapsed.dispose();
    _isRunning.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _wholeWidgetRebuilds++;

    return ExampleScreen(
      title: 'ValueNotifier',
      description:
          'ValueNotifier notifica a sus oyentes cuando cambia su valor. '
          'ValueListenableBuilder reconstruye solo la parte envuelta, '
          'dejando el resto del árbol intacto. Observa la diferencia '
          'entre reconstrucciones del widget completo y del builder.',
      code: _codeString,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Contador de reconstrucciones del widget completo
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.orange.shade200),
            ),
            child: Text(
              'Reconstrucciones del widget completo: $_wholeWidgetRebuilds',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.orange.shade800,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Demo 1: Contador con ValueListenableBuilder
          _SectionTitle('1. Contador (solo el número se redibuja)'),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton.filledTonal(
                onPressed: _decrement,
                icon: const Icon(Icons.remove),
              ),
              const SizedBox(width: 16),
              // Solo esta parte se reconstruye
              ValueListenableBuilder<int>(
                valueListenable: _counter,
                builder: (context, value, _) {
                  return Text(
                    '$value',
                    style: Theme.of(context).textTheme.headlineMedium,
                  );
                },
              ),
              const SizedBox(width: 16),
              IconButton.filledTonal(
                onPressed: _increment,
                icon: const Icon(Icons.add),
              ),
            ],
          ),
          const Divider(height: 32),

          // Demo 2: Cronómetro con ValueListenableBuilder
          _SectionTitle('2. Cronómetro'),
          Center(
            child: ValueListenableBuilder<Duration>(
              valueListenable: _elapsed,
              builder: (context, duration, _) {
                final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
                final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
                final millis = (duration.inMilliseconds.remainder(1000) ~/ 10).toString().padLeft(2, '0');
                return Text(
                  '$minutes:$seconds.$millis',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.bold,
                      ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ValueListenableBuilder<bool>(
                valueListenable: _isRunning,
                builder: (context, running, _) {
                  return FilledButton.icon(
                    onPressed: _toggleTimer,
                    icon: Icon(running ? Icons.pause : Icons.play_arrow),
                    label: Text(running ? 'Pausar' : 'Iniciar'),
                  );
                },
              ),
              const SizedBox(width: 8),
              OutlinedButton.icon(
                onPressed: _resetTimer,
                icon: const Icon(Icons.replay),
                label: const Text('Reiniciar'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }
}

const String _codeString = '''
class Counter extends StatelessWidget {
  final ValueNotifier<int> _counter = ValueNotifier<int>(0);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: _counter,
      builder: (context, value, child) {
        return Text('Valor: \$value');
      },
    );
  }
}

// Incrementar desde cualquier sitio:
_counter.value++;
'''
;
