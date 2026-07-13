import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:sample_app/ui/core/example_screen.dart';

/// Ejemplo didáctico de DELETE en una API REST.
///
/// Muestra una lista de posts obtenidos de JSONPlaceholder.
/// Cada elemento es Dismissible: al deslizarlo se muestra un diálogo
/// de confirmación y luego se envía una petición DELETE.
/// Se muestra un SnackBar con opción de deshacer.
class ApiDeleteExample extends StatefulWidget {
  const ApiDeleteExample({super.key});

  @override
  State<ApiDeleteExample> createState() => _ApiDeleteExampleState();
}

class _ApiDeleteExampleState extends State<ApiDeleteExample> {
  List<Post> _posts = [];
  bool _isLoading = true;
  String? _error;
  Post? _lastRemoved;
  int? _lastRemovedIndex;

  @override
  void initState() {
    super.initState();
    _fetchPosts();
  }

  Future<void> _fetchPosts() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      const url = 'https://jsonplaceholder.typicode.com/posts?_limit=15';
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body);
        setState(() {
          _posts = jsonList.map((json) => Post.fromJson(json)).toList();
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

  Future<void> _deletePost(int index) async {
    final post = _posts[index];

    try {
      final url = 'https://jsonplaceholder.typicode.com/posts/${post.id}';
      final response = await http.delete(Uri.parse(url));

      if (response.statusCode == 200 || response.statusCode == 204) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Post ${post.id} eliminado'),
            action: SnackBarAction(
              label: 'Deshacer',
              onPressed: () {
                setState(() {
                  if (_lastRemovedIndex != null && _lastRemoved != null) {
                    _posts.insert(_lastRemovedIndex!, _lastRemoved!);
                    _lastRemoved = null;
                    _lastRemovedIndex = null;
                  }
                });
              },
            ),
          ),
        );
      } else {
        if (!mounted) return;

        setState(() {
          _posts.insert(index, post);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al eliminar: ${response.statusCode}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _posts.insert(index, post);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error de red: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  Future<bool> _confirmDelete(String title) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar post'),
        content: Text('¿Eliminar "$title"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    return result == true;
  }

  @override
  Widget build(BuildContext context) {
    return ExampleScreen(
      title: 'API DELETE',
      description:
          'Este ejemplo obtiene posts de JSONPlaceholder y permite '
          'eliminarlos deslizando. Se confirma con un diálogo, se envía '
          'una petición DELETE y se muestra un SnackBar con opción de deshacer.',
      code: '''import 'package:http/http.dart' as http;
import 'dart:convert';

// Obtener posts
final response = await http.get(
  Uri.parse('https://api.example.com/posts?_limit=15'),
);
final posts = jsonDecode(response.body);

// Eliminar post con confirmación y undo
Future<void> deletePost(int id) async {
  final response = await http.delete(
    Uri.parse('https://api.example.com/posts/\$id'),
  );

  if (response.statusCode == 200) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Post eliminado'),
        action: SnackBarAction(
          label: 'Deshacer',
          onPressed: () => restorePost(),
        ),
      ),
    );
  }
}''',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_isLoading)
            const SizedBox(
              height: 300,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Cargando posts...'),
                  ],
                ),
              ),
            )
          else if (_error != null)
            Center(
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
                    'Error',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _error!,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    onPressed: _fetchPosts,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Reintentar'),
                  ),
                ],
              ),
            )
          else if (_posts.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'No quedan posts. Pulsa recargar para restaurar.',
                  textAlign: TextAlign.center,
                ),
              ),
            )
          else
            SizedBox(
              height: 380,
              child: ListView.builder(
                itemCount: _posts.length,
                itemBuilder: (context, index) {
                  final post = _posts[index];
                  return Dismissible(
                    key: ValueKey('post-${post.id}'),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20),
                      color: Colors.red,
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text('Eliminar',
                              style: TextStyle(color: Colors.white)),
                          SizedBox(width: 8),
                          Icon(Icons.delete, color: Colors.white),
                        ],
                      ),
                    ),
                    confirmDismiss: (direction) async {
                      return await _confirmDelete(post.title);
                    },
                    onDismissed: (direction) async {
                      setState(() {
                        _lastRemoved = _posts.removeAt(index);
                        _lastRemovedIndex = index;
                      });
                      await _deletePost(index);
                    },
                    child: Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          child: Text('${post.id}'),
                        ),
                        title: Text(post.title),
                        subtitle: Text(
                          post.body,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: _fetchPosts,
            icon: const Icon(Icons.refresh),
            label: const Text('Recargar posts'),
          ),
        ],
      ),
    );
  }
}

class Post {
  const Post({
    required this.id,
    required this.title,
    required this.body,
  });

  final int id;
  final String title;
  final String body;

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'] as int,
      title: json['title'] as String,
      body: json['body'] as String,
    );
  }
}
