import 'package:flutter/material.dart';
import 'package:sample_app/ui/core/example_screen.dart';

/// Lista con checkbox (checklist): items que se pueden marcar/desmarcar.
class ChecklistListExample extends StatefulWidget {
  const ChecklistListExample({super.key});

  @override
  State<ChecklistListExample> createState() => _ChecklistListExampleState();
}

class _ChecklistListExampleState extends State<ChecklistListExample> {
  final Map<String, bool> _tasks = {
    'Comprar leche': false,
    'Estudiar Flutter': false,
    'Revisar PR': false,
    'Actualizar dependencias': false,
    'Escribir tests': false,
    'Hacer deploy': false,
    'Documentar API': false,
    'Revisar diseño': false,
  };

  int get _doneCount => _tasks.values.where((v) => v).length;
  double get _progress => _tasks.isEmpty ? 0 : _doneCount / _tasks.length;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    const code = '''
Map<String, bool> tasks = { ... };

ListView(
  children: tasks.keys.map((task) {
    return CheckboxListTile(
      value: tasks[task],
      onChanged: (val) => setState(() => tasks[task] = val!),
      title: Text(task),
      secondary: Icon(Icons.check_circle),
    );
  }).toList(),
)''';

    return ExampleScreen(
      title: 'Lista tipo checklist',
      description: 'CheckboxListTile combina un checkbox con un título y '
          'subtítulo. Ideal para listas de tareas donde el usuario marca '
          'elementos completados.',
      code: code,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Barra de progreso
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Progreso: $_doneCount / ${_tasks.length}',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: _progress,
                      minHeight: 8,
                      backgroundColor: colorScheme.surfaceContainerHighest,
                      valueColor: AlwaysStoppedAnimation(colorScheme.primary),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Lista de tareas
          SizedBox(
            height: 320,
            child: ListView(
              children: _tasks.keys.map((task) {
                final done = _tasks[task]!;
                return CheckboxListTile(
                  value: done,
                  onChanged: (val) => setState(() => _tasks[task] = val!),
                  title: Text(
                    task,
                    style: TextStyle(
                      decoration: done ? TextDecoration.lineThrough : null,
                      color: done ? Colors.grey : null,
                    ),
                  ),
                  secondary: Icon(
                    done ? Icons.check_circle : Icons.radio_button_unchecked,
                    color: done ? colorScheme.primary : Colors.grey,
                  ),
                  controlAffinity: ListTileControlAffinity.leading,
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}