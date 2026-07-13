import 'package:flutter/material.dart';
import 'package:sample_app/ui/core/example_screen.dart';

/// Ejemplo didáctico de InheritedWidget.
///
/// Demuestra cómo compartir estado descendiente sin prop drilling,
/// y cómo todos los widgets dependientes se actualizan al mismo tiempo.
class InheritedWidgetExample extends StatefulWidget {
  const InheritedWidgetExample({super.key});

  @override
  State<InheritedWidgetExample> createState() => _InheritedWidgetExampleState();
}

class _InheritedWidgetExampleState extends State<InheritedWidgetExample> {
  int _counter = 0;

  void _increment() => setState(() => _counter++);

  @override
  Widget build(BuildContext context) {
    return ExampleScreen(
      title: 'InheritedWidget',
      description:
          'InheritedWidget permite compartir datos hacia abajo en el árbol '
          'de widgets. Los descendientes acceden al estado con dependencia '
          'implícita: cuando updateShouldNotify devuelve true, '
          'todos los widgets que lo consumen se reconstruyen automáticamente. '
          'Compara el resultado con el botón anidado al final.',
      code: _codeString,
      child: _CounterInheritedWidget(
        counter: _counter,
        onIncrement: _increment,
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _DescendantA(),
            SizedBox(height: 12),
            _DescendantB(),
            SizedBox(height: 12),
            _DeeplyNestedButton(),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// InheritedWidget
// ---------------------------------------------------------------------------
class _CounterInheritedWidget extends InheritedWidget {
  const _CounterInheritedWidget({
    required this.counter,
    required this.onIncrement,
    required super.child,
  });

  final int counter;
  final VoidCallback onIncrement;

  static _CounterInheritedWidget of(BuildContext context) {
    final widget = context.dependOnInheritedWidgetOfExactType<_CounterInheritedWidget>();
    assert(widget != null, 'No _CounterInheritedWidget found in context');
    return widget!;
  }

  @override
  bool updateShouldNotify(_CounterInheritedWidget oldWidget) {
    return oldWidget.counter != counter;
  }
}

// ---------------------------------------------------------------------------
// Descendientes
// ---------------------------------------------------------------------------
class _DescendantA extends StatelessWidget {
  const _DescendantA();

  @override
  Widget build(BuildContext context) {
    final inherited = _CounterInheritedWidget.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Descendiente A',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 4),
          Text('Valor heredado: ${inherited.counter}'),
        ],
      ),
    );
  }
}

class _DescendantB extends StatelessWidget {
  const _DescendantB();

  @override
  Widget build(BuildContext context) {
    final inherited = _CounterInheritedWidget.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.purple.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.purple.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Descendiente B',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 4),
          Text('Valor heredado: ${inherited.counter}'),
        ],
      ),
    );
  }
}

class _DeeplyNestedButton extends StatelessWidget {
  const _DeeplyNestedButton();

  @override
  Widget build(BuildContext context) {
    final inherited = _CounterInheritedWidget.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Botón profundamente anidado',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 4),
          Text('Valor actual: ${inherited.counter}'),
          const SizedBox(height: 8),
          FilledButton.icon(
            onPressed: inherited.onIncrement,
            icon: const Icon(Icons.add),
            label: const Text('Incrementar desde aquí'),
          ),
        ],
      ),
    );
  }
}

const String _codeString = '''
class MyInherited extends InheritedWidget {
  const MyInherited({
    required this.counter,
    required super.child,
  });

  final int counter;

  static MyInherited of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<MyInherited>()!;
  }

  @override
  bool updateShouldNotify(MyInherited old) {
    return old.counter != counter;
  }
}

// Uso en cualquier descendiente:
final value = MyInherited.of(context).counter;
'''
;
