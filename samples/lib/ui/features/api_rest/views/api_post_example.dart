import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:sample_app/ui/core/example_screen.dart';

/// Ejemplo didáctico de API POST para crear una publicación.
///
/// Muestra un formulario con título y contenido, valida los campos,
/// realiza una petición POST con JSON y muestra la respuesta del servidor.
class ApiPostExample extends StatefulWidget {
  const ApiPostExample({super.key});

  @override
  State<ApiPostExample> createState() => _ApiPostExampleState();
}

class _ApiPostExampleState extends State<ApiPostExample> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();
  bool _isSubmitting = false;
  PostResult? _result;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
      _result = null;
    });

    try {
      final response = await http.post(
        Uri.parse('https://jsonplaceholder.typicode.com/posts'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode({
          'title': _titleController.text,
          'body': _bodyController.text,
          'userId': 1,
        }),
      );

      if (response.statusCode == 201) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        setState(() {
          _result = PostResult(
            id: json['id'] as int,
            title: json['title'] as String,
            body: json['body'] as String,
            userId: json['userId'] as int,
          );
        });
      } else {
        setState(() {
          _result = PostResult.error('Error HTTP: ${response.statusCode}');
        });
      }
    } catch (e) {
      setState(() {
        _result = PostResult.error('Error de conexión: $e');
      });
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  void _reset() {
    _titleController.clear();
    _bodyController.clear();
    setState(() {
      _result = null;
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ExampleScreen(
      title: 'API POST — Crear',
      description:
          'Este ejemplo envía datos a una API REST usando http.post. '
          'Incluye validación de formulario, estado de carga y muestra '
          'la respuesta del servidor con el ID asignado.',
      code: '''import 'package:http/http.dart' as http;
import 'dart:convert';

final response = await http.post(
  Uri.parse('https://jsonplaceholder.typicode.com/posts'),
  headers: {
    'Content-Type': 'application/json; charset=UTF-8',
  },
  body: jsonEncode({
    'title': 'Mi título',
    'body': 'Mi contenido',
    'userId': 1,
  }),
);

if (response.statusCode == 201) {
  final json = jsonDecode(response.body);
  print('Creado con ID: \${json['id']}');
} else {
  throw Exception('Error: \${response.statusCode}');
}''',
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Título',
                hintText: 'Escribe el título de la publicación',
                prefixIcon: Icon(Icons.title),
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'El título es obligatorio';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _bodyController,
              decoration: const InputDecoration(
                labelText: 'Contenido',
                hintText: 'Escribe el contenido de la publicación',
                prefixIcon: Icon(Icons.article),
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'El contenido es obligatorio';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: _isSubmitting ? null : _submit,
                    icon: _isSubmitting
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.send),
                    label: Text(_isSubmitting ? 'Enviando...' : 'Crear'),
                  ),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: _isSubmitting ? null : _reset,
                  icon: const Icon(Icons.clear),
                  label: const Text('Limpiar'),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Resultado
            if (_result != null)
              _result!.isError
                  ? Card(
                      color: Theme.of(context).colorScheme.errorContainer,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Icon(
                              Icons.error_outline,
                              color: Theme.of(context).colorScheme.error,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _result!.errorMessage!,
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.error,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : Card(
                      color: Theme.of(context)
                          .colorScheme
                          .primaryContainer
                          .withAlpha(180),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.check_circle,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onPrimaryContainer,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '¡Creado exitosamente!',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onPrimaryContainer,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'ID asignado: ${_result!.id}',
                              style: TextStyle(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onPrimaryContainer,
                              ),
                            ),
                            Text(
                              'Título: ${_result!.title}',
                              style: TextStyle(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onPrimaryContainer,
                              ),
                            ),
                            Text(
                              'Contenido: ${_result!.body}',
                              style: TextStyle(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onPrimaryContainer,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
          ],
        ),
      ),
    );
  }
}

/// Resultado de la creación de una publicación.
class PostResult {
  const PostResult({
    required this.id,
    required this.title,
    required this.body,
    required this.userId,
  }) : isError = false,
       errorMessage = null;

  const PostResult.error(this.errorMessage)
      : isError = true,
        id = 0,
        title = '',
        body = '',
        userId = 0;

  final bool isError;
  final int id;
  final String title;
  final String body;
  final int userId;
  final String? errorMessage;
}
