import 'package:flutter/material.dart';
import 'package:sample_app/ui/core/example_screen.dart';

/// Lista genérica: el ListView más simple con ListTile.
class GenericListExample extends StatelessWidget {
  const GenericListExample({super.key});

  @override
  Widget build(BuildContext context) {
    const items = [
      'Madrid', 'Barcelona', 'Valencia', 'Sevilla', 'Bilbao',
      'Málaga', 'Zaragoza', 'Murcia', 'Palma', 'Valladolid',
      'Salamanca', 'Granada', 'Toledo', 'Santander', 'Cádiz',
    ];

    const code = '''
ListView.builder(
  itemCount: items.length,
  itemBuilder: (context, index) {
    return ListTile(
      leading: CircleAvatar(child: Text('\${index + 1}')),
      title: Text(items[index]),
      trailing: Icon(Icons.chevron_right),
      onTap: () => /* acción */,
    );
  },
)''';

    return ExampleScreen(
      title: 'Lista genérica',
      description: 'ListView.builder construye cada fila bajo demanda. '
          'Ideal para listas largas donde no todos los elementos están en pantalla.',
      code: code,
      child: SizedBox(
        height: 400,
        child: ListView.builder(
          itemCount: items.length,
          itemBuilder: (context, index) {
            return ListTile(
              leading: CircleAvatar(child: Text('${index + 1}')),
              title: Text(items[index]),
              subtitle: Text('Provincia #${index + 1}'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Tocaste ${items[index]}')),
              ),
            );
          },
        ),
      ),
    );
  }
}