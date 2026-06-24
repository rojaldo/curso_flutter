import 'package:flutter/material.dart';
import 'package:sample_app/ui/core/example_screen.dart';

/// Demuestra el ciclo de vida de un StatefulWidget.
///
/// Muestra initState, didUpdateWidget, didChangeDependencies, deactivate,
/// dispose y rebuild con logs visibles en pantalla.
class WidgetLifecycleExample extends StatefulWidget {
  const WidgetLifecycleExample({super.key});

  @override
  State<WidgetLifecycleExample> createState() => _WidgetLifecycleExampleState();
}

class _WidgetLifecycleExampleState extends State<WidgetLifecycleExample> {
  final ValueNotifier<List<String>> _logs = ValueNotifier([]);
  bool _showChild = true;
  int _parentValue = 0;

  void _log(String message) {
    final now = DateTime.now();
    final entry = '${now.hour.toString().padLeft(2, '0')}:'
        '${now.minute.toString().padLeft(2, '0')}:'
        '${now.second.toString().padLeft(2, '0')} — $message';
    final updated = [entry, ..._logs.value];
    if (updated.length > 50) updated.removeLast();
    _logs.value = updated;
  }

  @override
  void dispose() {
    _logs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const code = '''
class _MiWidgetState extends State<MiWidget> {
  @override
  void initState() {
    super.initState();
    // Se llama UNA VEZ al crearse el State
    print('initState');
  }

  @override
  void didUpdateWidget(MiWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Se llama cuando el padre reconstruye con nuevas propiedades
    if (widget.valor != oldWidget.valor) {
      print('Propiedad cambió');
    }
  }

  @override
  void dispose() {
    // Se llama al eliminarse el widget
    print('dispose');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text('Valor: \${widget.valor}');
  }
}
''';

    return ExampleScreen(
      title: 'Ciclo de vida del Widget',
      description: 'Cada StatefulWidget tiene un ciclo de vida: se crea (initState), '
          'se actualiza (didUpdateWidget, didChangeDependencies), y se destruye '
          '(dispose). Usa los botones para montar/desmontar y cambiar propiedades, '
          'y observa los logs.',
      code: code,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilledButton.icon(
                onPressed: () => setState(() => _parentValue++),
                icon: const Icon(Icons.refresh),
                label: const Text('Cambiar propiedad'),
              ),
              FilledButton.icon(
                onPressed: () {
                  setState(() => _showChild = !_showChild);
                  _log(_showChild ? '▶ Montar widget' : '■ Desmontar widget');
                },
                icon: Icon(_showChild ? Icons.visibility_off : Icons.visibility),
                label: Text(_showChild ? 'Desmontar' : 'Montar'),
              ),
              OutlinedButton.icon(
                onPressed: () => _logs.value = [],
                icon: const Icon(Icons.delete_sweep),
                label: const Text('Limpiar logs'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            height: 80,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: _showChild
                  ? Colors.green.shade50
                  : Colors.grey.shade200,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: _showChild ? Colors.green : Colors.grey,
              ),
            ),
            child: _showChild
                ? _LifecycleChild(
                    value: _parentValue,
                    onLog: _log,
                  )
                : const Text(
                    'Widget desmontado',
                    style: TextStyle(color: Colors.grey),
                  ),
          ),
          const SizedBox(height: 16),
          const Text('Logs del ciclo de vida:', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: Colors.black87,
              borderRadius: BorderRadius.circular(8),
            ),
            child: ValueListenableBuilder<List<String>>(
              valueListenable: _logs,
              builder: (context, logs, _) {
                return ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: logs.length,
                  itemBuilder: (context, index) {
                    final log = logs[index];
                    final color = log.contains('initState')
                        ? Colors.greenAccent
                        : log.contains('dispose')
                            ? Colors.redAccent
                            : log.contains('didUpdate')
                                ? Colors.orangeAccent
                                : log.contains('build')
                                    ? Colors.white60
                                    : Colors.white;
                    return Text(log, style: TextStyle(fontFamily: 'monospace', fontSize: 12, color: color));
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _LifecycleChild extends StatefulWidget {
  const _LifecycleChild({required this.value, required this.onLog});

  final int value;
  final void Function(String) onLog;

  @override
  State<_LifecycleChild> createState() => _LifecycleChildState();
}

class _LifecycleChildState extends State<_LifecycleChild> {
  int _buildCount = 0;

  @override
  void initState() {
    super.initState();
    widget.onLog('🟢 initState — Widget creado');
  }

  @override
  void didUpdateWidget(_LifecycleChild oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) {
      widget.onLog('🟠 didUpdateWidget — valor: ${oldWidget.value} → ${widget.value}');
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    widget.onLog('🔵 didChangeDependencies');
  }

  @override
  void deactivate() {
    widget.onLog('🟡 deactivate');
    super.deactivate();
  }

  @override
  void dispose() {
    widget.onLog('🔴 dispose — Widget destruido');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _buildCount++;
    widget.onLog('⚪ build #$_buildCount — valor: ${widget.value}');
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'valor = ${widget.value}',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Text('build() llamado $_buildCount veces', style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}