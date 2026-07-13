import 'package:flutter/material.dart';
import 'package:sample_app/ui/core/example_screen.dart';

/// Ejemplo didáctico de FutureBuilder en Flutter.
///
/// Simula una petición de red con Future.delayed, muestra estados
/// de carga, datos y error, y permite reintentar.
class FutureBuilderExample extends StatefulWidget {
  const FutureBuilderExample({super.key});

  @override
  State<FutureBuilderExample> createState() => _FutureBuilderExampleState();
}

class _FutureBuilderExampleState extends State<FutureBuilderExample> {
  Future<String>? _future;
  bool _shouldFail = false;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  void _refresh() {
    setState(() {
      _shouldFail = false;
      _future = _fetchData();
    });
  }

  void _triggerError() {
    setState(() {
      _shouldFail = true;
      _future = _fetchData();
    });
  }

  Future<String> _fetchData() async {
    await Future.delayed(const Duration(seconds: 2));
    if (_shouldFail) {
      throw Exception('Error de conexión simulado');
    }
    return 'Datos cargados exitosamente desde el servidor. '
        'Timestamp: ${DateTime.now().toIso8601String()}';
  }

  @override
  Widget build(BuildContext context) {
    return ExampleScreen(
      title: 'FutureBuilder',
      description:
          'FutureBuilder reacciona al estado de un Future. '
          'Muestra un indicador de carga mientras espera, los datos '
          'cuando se completan, y un mensaje de error si algo falla.',
      code: '''FutureBuilder<String>(
  future: _fetchData(),
  builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return CircularProgressIndicator();
    }
    if (snapshot.hasError) {
      return Text('Error: \${snapshot.error}');
    }
    if (snapshot.hasData) {
      return Text('Datos: \${snapshot.data}');
    }
    return Text('Esperando...');
  },
)''',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Controles
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FilledButton.icon(
                onPressed: _refresh,
                icon: const Icon(Icons.refresh),
                label: const Text('Refrescar'),
              ),
              const SizedBox(width: 8),
              OutlinedButton.icon(
                onPressed: _triggerError,
                icon: const Icon(Icons.error_outline),
                label: const Text('Simular error'),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Estado del FutureBuilder
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: FutureBuilder<String>(
              future: _future,
              builder: (context, snapshot) {
                // Estado: esperando
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Cargando datos...'),
                    ],
                  );
                }

                // Estado: error
                if (snapshot.hasError) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 48,
                        color: Theme.of(context).colorScheme.error,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Error: ${snapshot.error}',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                      const SizedBox(height: 12),
                      FilledButton.icon(
                        onPressed: _refresh,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Reintentar'),
                      ),
                    ],
                  );
                }

                // Estado: datos recibidos
                if (snapshot.hasData) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.check_circle,
                        size: 48,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        snapshot.data!,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ],
                  );
                }

                // Estado inicial
                return const Text('Presiona Refrescar para cargar datos');
              },
            ),
          ),
          const SizedBox(height: 16),

          // Explicación de estados
          _buildStateLegend(),
        ],
      ),
    );
  }

  Widget _buildStateLegend() {
    final states = [
      ('ConnectionState.none', 'Future no iniciado'),
      ('ConnectionState.waiting', 'Esperando resultado'),
      ('ConnectionState.active', 'Stream activo (no aplica a Future)'),
      ('ConnectionState.done', 'Future completado'),
      ('snapshot.hasData', 'Datos disponibles'),
      ('snapshot.hasError', 'Ocurrió un error'),
    ];

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.amber.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Estados de ConnectionState:',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          ...states.map((s) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('• ', style: TextStyle(color: Colors.amber.shade800)),
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        style: TextStyle(
                          color: Colors.amber.shade900,
                          fontSize: 12,
                        ),
                        children: [
                          TextSpan(
                            text: s.$1,
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextSpan(text: ' — ${s.$2}'),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
