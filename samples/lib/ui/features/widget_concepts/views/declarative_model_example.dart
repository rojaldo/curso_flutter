import 'package:flutter/material.dart';
import 'package:sample_app/ui/core/example_screen.dart';

/// Demuestra el modelo declarativo de Flutter vs el imperativo.
///
/// Muestra cómo en Flutter describes QUÉ quieres (el resultado final),
/// no CÓMO llegar ahí (mutaciones paso a paso).
class DeclarativeModelExample extends StatefulWidget {
  const DeclarativeModelExample({super.key});

  @override
  State<DeclarativeModelExample> createState() => _DeclarativeModelExampleState();
}

class _DeclarativeModelExampleState extends State<DeclarativeModelExample> {
  bool _isDark = false;
  bool _showImage = true;
  double _fontSize = 16;
  String _text = 'Hola Flutter';

  @override
  Widget build(BuildContext context) {
    const code = '''
// ❌ IMPERATIVO (Android/iOS clásico):
textView.setText("Nuevo texto");
textView.setTextColor(Color.RED);
textView.setVisibility(View.VISIBLE);

// ✅ DECLARATIVO (Flutter):
// Describes el RESULTADO FINAL.
// Flutter compara con el estado anterior
// y actualiza solo lo que cambió.
Text(
  _text,
  style: TextStyle(
    fontSize: _fontSize,
    color: _isDark ? Colors.white : Colors.black,
  ),
)

// No "modificas" el widget.
// Creas una NUEVA descripción y Flutter
// determina los cambios mínimos necesarios.
''';

    return ExampleScreen(
      title: 'Modelo declarativo — Describe QUÉ, no CÓMO',
      description: 'En Flutter describes el resultado final, no los pasos para '
          'llegar ahí. Cambia los controles y observa cómo la UI se reconstruye '
          'completamente a partir del nuevo estado, sin mutaciones manuales.',
      code: code,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Controles declarativos
          SwitchListTile(
            title: const Text('Modo oscuro'),
            value: _isDark,
            onChanged: (v) => setState(() => _isDark = v),
          ),
          SwitchListTile(
            title: const Text('Mostrar imagen'),
            value: _showImage,
            onChanged: (v) => setState(() => _showImage = v),
          ),
          ListTile(
            title: const Text('Tamaño de texto'),
            trailing: Text('${_fontSize.round()}px', style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
          Slider(
            value: _fontSize,
            min: 12,
            max: 32,
            divisions: 10,
            onChanged: (v) => setState(() => _fontSize = v),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              decoration: const InputDecoration(labelText: 'Texto', border: OutlineInputBorder()),
              onChanged: (v) => setState(() => _text = v),
              controller: TextEditingController(text: _text)..selection = TextSelection.collapsed(offset: _text.length),
            ),
          ),
          const SizedBox(height: 16),
          // Resultado declarativo
          const Divider(),
          const SizedBox(height: 8),
          const Text('Resultado declarativo:', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _isDark ? Colors.grey.shade900 : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _isDark ? Colors.grey : Colors.grey.shade300),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_showImage)
                  Container(
                    height: 80,
                    width: 80,
                    decoration: BoxDecoration(
                      color: _isDark ? Colors.deepPurple.shade200 : Colors.deepPurple.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.flutter_dash, size: 48, color: _isDark ? Colors.white : Colors.deepPurple),
                  ),
                if (_showImage) const SizedBox(height: 12),
                Text(
                  _text.isEmpty ? '...' : _text,
                  style: TextStyle(
                    fontSize: _fontSize,
                    color: _isDark ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Este widget se reconstruye completamente\n'
                  'a partir del estado. No hay mutaciones.',
                  style: TextStyle(
                    fontSize: 12,
                    color: _isDark ? Colors.grey.shade400 : Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              '💡 En imperativo: textView.setText(), textView.setColor()\n'
              '   En declarativo: describes el resultado, Flutter\n'
              '   compara estados y aplica los cambios mínimos.',
              style: TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}