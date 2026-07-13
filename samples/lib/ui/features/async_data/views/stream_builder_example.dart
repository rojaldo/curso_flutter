import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sample_app/ui/core/example_screen.dart';

/// Ejemplo didáctico de StreamBuilder en Flutter.
///
/// Muestra un contador que incrementa cada segundo usando Stream.periodic,
/// un temporizador de cuenta regresiva, y controles de inicio/pausa/reinicio.
class StreamBuilderExample extends StatefulWidget {
  const StreamBuilderExample({super.key});

  @override
  State<StreamBuilderExample> createState() => _StreamBuilderExampleState();
}

class _StreamBuilderExampleState extends State<StreamBuilderExample> {
  late StreamController<int> _counterController;
  late StreamController<int> _timerController;
  Timer? _counterTimer;
  Timer? _countdownTimer;
  int _counterValue = 0;
  int _countdownValue = 10;
  bool _isCounterRunning = false;
  bool _isTimerRunning = false;

  @override
  void initState() {
    super.initState();
    _counterController = StreamController<int>.broadcast();
    _timerController = StreamController<int>.broadcast();
  }

  @override
  void dispose() {
    _counterTimer?.cancel();
    _countdownTimer?.cancel();
    _counterController.close();
    _timerController.close();
    super.dispose();
  }

  // Contador ascendente
  void _startCounter() {
    if (_isCounterRunning) return;
    setState(() => _isCounterRunning = true);
    _counterTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _counterValue++;
      if (!_counterController.isClosed) {
        _counterController.add(_counterValue);
      }
    });
  }

  void _pauseCounter() {
    _counterTimer?.cancel();
    setState(() => _isCounterRunning = false);
  }

  void _resetCounter() {
    _counterTimer?.cancel();
    setState(() {
      _isCounterRunning = false;
      _counterValue = 0;
    });
    if (!_counterController.isClosed) {
      _counterController.add(0);
    }
  }

  // Temporizador de cuenta regresiva
  void _startTimer() {
    if (_isTimerRunning || _countdownValue <= 0) return;
    setState(() => _isTimerRunning = true);
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdownValue > 0) {
        _countdownValue--;
        if (!_timerController.isClosed) {
          _timerController.add(_countdownValue);
        }
      } else {
        timer.cancel();
        setState(() => _isTimerRunning = false);
      }
    });
  }

  void _pauseTimer() {
    _countdownTimer?.cancel();
    setState(() => _isTimerRunning = false);
  }

  void _resetTimer() {
    _countdownTimer?.cancel();
    setState(() {
      _isTimerRunning = false;
      _countdownValue = 10;
    });
    if (!_timerController.isClosed) {
      _timerController.add(10);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ExampleScreen(
      title: 'StreamBuilder',
      description:
          'StreamBuilder escucha un Stream y reconstruye la UI con cada '
          'nuevo evento. Es ideal para datos en tiempo real: contadores, '
          'temporizadores, sensores, chat, etc.',
      code: '''StreamBuilder<int>(
  stream: _stream,
  builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return Text('Esperando...');
    }
    if (snapshot.connectionState == ConnectionState.active) {
      return Text('Valor: \${snapshot.data}');
    }
    if (snapshot.connectionState == ConnectionState.done) {
      return Text('Stream finalizado');
    }
    return Text('Sin datos');
  },
)

// Crear un stream periódico
Stream.periodic(
  Duration(seconds: 1),
  (count) => count,
);''',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Contador ascendente
          _buildSectionTitle('Contador ascendente'),
          Center(
            child: StreamBuilder<int>(
              stream: _counterController.stream,
              initialData: 0,
              builder: (context, snapshot) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${snapshot.data}',
                      style: Theme.of(context).textTheme.displayLarge,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Estado: ${_connectionStateName(snapshot.connectionState)}',
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FilledButton.icon(
                onPressed: _isCounterRunning ? null : _startCounter,
                icon: const Icon(Icons.play_arrow),
                label: const Text('Iniciar'),
              ),
              const SizedBox(width: 8),
              OutlinedButton.icon(
                onPressed: _isCounterRunning ? _pauseCounter : null,
                icon: const Icon(Icons.pause),
                label: const Text('Pausar'),
              ),
              const SizedBox(width: 8),
              TextButton.icon(
                onPressed: _resetCounter,
                icon: const Icon(Icons.replay),
                label: const Text('Reiniciar'),
              ),
            ],
          ),
          const Divider(height: 32),

          // Temporizador de cuenta regresiva
          _buildSectionTitle('Temporizador regresivo'),
          Center(
            child: StreamBuilder<int>(
              stream: _timerController.stream,
              initialData: 10,
              builder: (context, snapshot) {
                final value = snapshot.data ?? 10;
                final isDone = value == 0;
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${value}s',
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(
                            color: isDone
                                ? Theme.of(context).colorScheme.error
                                : null,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Estado: ${_connectionStateName(snapshot.connectionState)}',
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                    if (isDone)
                      Text(
                        '¡Tiempo terminado!',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FilledButton.icon(
                onPressed: _isTimerRunning || _countdownValue == 0
                    ? null
                    : _startTimer,
                icon: const Icon(Icons.play_arrow),
                label: const Text('Iniciar'),
              ),
              const SizedBox(width: 8),
              OutlinedButton.icon(
                onPressed: _isTimerRunning ? _pauseTimer : null,
                icon: const Icon(Icons.pause),
                label: const Text('Pausar'),
              ),
              const SizedBox(width: 8),
              TextButton.icon(
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

  Widget _buildSectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }

  String _connectionStateName(ConnectionState state) {
    switch (state) {
      case ConnectionState.none:
        return 'none';
      case ConnectionState.waiting:
        return 'waiting';
      case ConnectionState.active:
        return 'active';
      case ConnectionState.done:
        return 'done';
    }
  }
}
