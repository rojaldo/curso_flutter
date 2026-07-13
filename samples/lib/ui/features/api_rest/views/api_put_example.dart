import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:sample_app/ui/core/example_screen.dart';

/// Ejemplo didáctico de API PUT para actualizar una publicación.
///
/// Carga una publicación existente, pre-rellena un formulario,
/// permite editar y envía los cambios con http.put.
/// Muestra comparación antes/después de la actualización.
class ApiPutExample extends StatefulWidget {
  const ApiPutExample({super.key});

  @override
  State<ApiPutExample> createState() => _ApiPutExampleState();
}

class _ApiPutExampleState extends State<ApiPutExample> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();

  String _originalTitle = '';
  String _originalBody = '';
  bool _isLoading = true;
  bool _isUpdating = false;
  String? _error;
  PostUpdateResult? _result;

  @override
  void initState() {
    super.initState();
    _fetchPost();
  }

  Future<void> _fetchPost() async {
    setState(() {
      _isLoading = true;
      _error = null;
      _result = null;
    });

    try {
      final response = await http.get(
        Uri.parse('https://jsonplaceholder.typicode.com/posts/1'),
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        final title = json['title'] as String;
        final body = json['body'] as String;
        setState(() {
          _originalTitle = title;
          _originalBody = body;
          _titleController.text = title;
          _bodyController.text = body;
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'Error HTTP: ${response.statusCode}';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error de conexión: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _updatePost() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isUpdating = true;
      _result = null;
    });

    try {
      final response = await http.put(
        Uri.parse('https://jsonplaceholder.typicode.com/posts/1'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode({
          'id': 1,
          'title': _titleController.text,
          'body': _bodyController.text,
          'userId': 1,
        }),
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        setState(() {
          _result = PostUpdateResult(
            id: json['id'] as int,
            title: json['title'] as String,
            body: json['body'] as String,
            userId: json['userId'] as int,
          );
          _originalTitle = _titleController.text;
          _originalBody = _bodyController.text;
        });
      } else {
        setState(() {
          _result = PostUpdateResult.error('Error HTTP: ${response.statusCode}');
        });
      }
    } catch (e) {
      setState(() {
        _result = PostUpdateResult.error('Error de conexión: $e');
      });
    } finally {
      setState(() {
        _isUpdating = false;
      });
    }
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
      title: 'API PUT — Actualizar',
      description:
          'Este ejemplo carga una publicación existente, permite editarla '
          'y envía los cambios con http.put. Muestra comparación antes/después.',
      code: '''import 'package:http/http.dart' as http;
import 'dart:convert';

// Cargar publicación existente
final getResponse = await http.get(
  Uri.parse('https://jsonplaceholder.typicode.com/posts/1'),
);

// Enviar actualización con PUT
final putResponse = await http.put(
  Uri.parse('https://jsonplaceholder.typicode.com/posts/1'),
  headers: {
    'Content-Type': 'application/json; charset=UTF-8',
  },
  body: jsonEncode({
    'id': 1,
    'title': 'Nuevo título',
    'body': 'Nuevo contenido',
    'userId': 1,
  }),
);

if (putResponse.statusCode == 200) {
  final json = jsonDecode(putResponse.body);
  print('Actualizado: \${json['title']}');
}''',
      child: _isLoading
          ? const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Cargando publicación...'),
                ],
              ),
            )
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.signal_wifi_off,
                        size: 48,
                        color: Theme.of(context).colorScheme.error,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Error al cargar',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _error!,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 12),
                      FilledButton.icon(
                        onPressed: _fetchPost,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Reintentar'),
                      ),
                    ],
                  ),
                )
              : Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Datos originales
                      Card(
                        color: Colors.grey.shade100,
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Datos originales',
                                style: Theme.of(context)
                                    .textTheme
                                    .labelSmall
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Título: $_originalTitle',
                                style: const TextStyle(fontSize: 13),
                              ),
                              Text(
                                'Contenido: $_originalBody',
                                style: const TextStyle(fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Formulario de edición
                      TextFormField(
                        controller: _titleController,
                        decoration: const InputDecoration(
                          labelText: 'Nuevo título',
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
                          labelText: 'Nuevo contenido',
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
                              onPressed: _isUpdating ? null : _updatePost,
                              icon: _isUpdating
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Icon(Icons.save),
                              label: Text(
                                _isUpdating ? 'Actualizando...' : 'Guardar',
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          OutlinedButton.icon(
                            onPressed: _isUpdating ? null : _fetchPost,
                            icon: const Icon(Icons.refresh),
                            label: const Text('Recargar'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Resultado
                      if (_result != null)
                        _result!.isError
                            ? Card(
                                color:
                                    Theme.of(context).colorScheme.errorContainer,
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.error_outline,
                                        color:
                                            Theme.of(context).colorScheme.error,
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          _result!.errorMessage!,
                                          style: TextStyle(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .error,
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                            '¡Actualizado exitosamente!',
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
                                        'ID: ${_result!.id}',
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

/// Resultado de la actualización de una publicación.
class PostUpdateResult {
  const PostUpdateResult({
    required this.id,
    required this.title,
    required this.body,
    required this.userId,
  }) : isError = false,
       errorMessage = null;

  const PostUpdateResult.error(this.errorMessage)
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
