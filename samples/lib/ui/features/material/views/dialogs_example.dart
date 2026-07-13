import 'package:flutter/material.dart';
import 'package:sample_app/ui/core/example_screen.dart';

class DialogsExample extends StatelessWidget {
  const DialogsExample({super.key});

  @override
  Widget build(BuildContext context) {
    return ExampleScreen(
      title: 'Diálogos y Snackbars',
      description:
          'Flutter ofrece varias formas de mostrar información emergente: '
          'AlertDialog para confirmaciones, SimpleDialog para selección, '
          'SnackBar para mensajes breves y BottomSheet para paneles deslizables.',
      code: '''showDialog(
  context: context,
  builder: (context) => AlertDialog(
    title: Text('Título'),
    content: Text('Mensaje'),
    actions: [
      TextButton(onPressed: () {}, child: Text('Cancelar')),
      FilledButton(onPressed: () {}, child: Text('Aceptar')),
    ],
  ),
);

ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(
    content: Text('Mensaje'),
    action: SnackBarAction(label: 'Deshacer', onPressed: () {}),
  ),
);''',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ElevatedButton.icon(
            onPressed: () => _showAlertDialog(context),
            icon: const Icon(Icons.warning_amber),
            label: const Text('Mostrar AlertDialog'),
          ),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: () => _showSimpleDialog(context),
            icon: const Icon(Icons.list),
            label: const Text('Mostrar SimpleDialog'),
          ),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: () => _showSnackBar(context),
            icon: const Icon(Icons.message),
            label: const Text('Mostrar SnackBar'),
          ),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: () => _showBottomSheet(context),
            icon: const Icon(Icons.vertical_align_bottom),
            label: const Text('Mostrar BottomSheet (modal)'),
          ),
        ],
      ),
    );
  }

  Future<void> _showAlertDialog(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirmar acción'),
          content: const Text(
            '¿Estás seguro de que deseas realizar esta acción?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Aceptar'),
            ),
          ],
        );
      },
    );
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result == true ? 'Acción aceptada' : 'Acción cancelada',
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _showSimpleDialog(BuildContext context) async {
    final result = await showDialog<String>(
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: const Text('Selecciona un idioma'),
          children: [
            SimpleDialogOption(
              onPressed: () => Navigator.of(context).pop('Español'),
              child: const Text('Español'),
            ),
            SimpleDialogOption(
              onPressed: () => Navigator.of(context).pop('Inglés'),
              child: const Text('Inglés'),
            ),
            SimpleDialogOption(
              onPressed: () => Navigator.of(context).pop('Francés'),
              child: const Text('Francés'),
            ),
          ],
        );
      },
    );
    if (context.mounted && result != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Seleccionado: $result')),
      );
    }
  }

  void _showSnackBar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Mensaje eliminado'),
        action: SnackBarAction(
          label: 'Deshacer',
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Acción deshecha')),
            );
          },
        ),
      ),
    );
  }

  Future<void> _showBottomSheet(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Opciones',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                ListTile(
                  leading: const Icon(Icons.share),
                  title: const Text('Compartir'),
                  onTap: () => Navigator.of(context).pop(),
                ),
                ListTile(
                  leading: const Icon(Icons.link),
                  title: const Text('Copiar enlace'),
                  onTap: () => Navigator.of(context).pop(),
                ),
                ListTile(
                  leading: const Icon(Icons.delete, color: Colors.red),
                  title: const Text('Eliminar',
                      style: TextStyle(color: Colors.red)),
                  onTap: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
