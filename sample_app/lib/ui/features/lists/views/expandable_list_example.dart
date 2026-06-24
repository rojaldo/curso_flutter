import 'package:flutter/material.dart';
import 'package:sample_app/ui/core/example_screen.dart';

/// Lista desplegable: ExpansionTile para mostrar/ocultar contenido por grupo.
class ExpandableListExample extends StatefulWidget {
  const ExpandableListExample({super.key});

  @override
  State<ExpandableListExample> createState() => _ExpandableListExampleState();
}

class _ExpandableListExampleState extends State<ExpandableListExample> {
  @override
  Widget build(BuildContext context) {
    const sections = [
      _Section('Frutas', Icons.eco, [
        'Manzana', 'Banana', 'Cereza', 'Durazno', 'Kiwi',
      ]),
      _Section('Verduras', Icons.grass, [
        'Brócoli', 'Zanahoria', 'Espinaca', 'Pimiento', 'Pepino',
      ]),
      _Section('Lácteos', Icons.local_drink, [
        'Leche', 'Queso', 'Yogur', 'Mantequilla',
      ]),
      _Section('Carnes', Icons.set_meal, [
        'Pollo', 'Ternera', 'Cerdo', 'Cordero',
      ]),
    ];

    const code = '''
ListView(
  children: sections.map((section) {
    return ExpansionTile(
      leading: Icon(section.icon),
      title: Text(section.name),
      children: section.items.map((item) {
        return ListTile(
          title: Text(item),
          trailing: Icon(Icons.add_shopping_cart),
        );
      }).toList(),
    );
  }).toList(),
)''';

    return ExampleScreen(
      title: 'Lista desplegable',
      description: 'ExpansionTile permite expandir y colapsar secciones dentro '
          'de una lista. Cada grupo muestra u oculta sus elementos al tocarlo.',
      code: code,
      child: SizedBox(
        height: 400,
        child: ListView(
          children: sections.map((section) {
            return ExpansionTile(
              leading: Icon(section.icon, color: Theme.of(context).colorScheme.primary),
              title: Text(section.name, style: const TextStyle(fontWeight: FontWeight.w600)),
              children: section.items.map((item) {
                return ListTile(
                  title: Text(item),
                  dense: true,
                  trailing: const Icon(Icons.add_shopping_cart, size: 18),
                  onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Añadido: $item')),
                  ),
                );
              }).toList(),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _Section {
  const _Section(this.name, this.icon, this.items);
  final String name;
  final IconData icon;
  final List<String> items;
}