import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:sample_app/ui/core/example_screen.dart';

/// Ejemplo didáctico de API GET con patrón maestro-detalle.
///
/// Muestra una lista de publicaciones desde JSONPlaceholder.
/// Al tocar una publicación, navega a una pantalla de detalle
/// que muestra la publicación completa y sus comentarios.
class ApiGetDetailExample extends StatefulWidget {
  const ApiGetDetailExample({super.key});

  @override
  State<ApiGetDetailExample> createState() => _ApiGetDetailExampleState();
}

class _ApiGetDetailExampleState extends State<ApiGetDetailExample> {
  List<Post> _posts = [];
  bool _isLoading = true;
  String? _error;

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
      final response = await http.get(
        Uri.parse(
          'https://jsonplaceholder.typicode.com/posts?_limit=10',
        ),
      );

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

  void _openDetail(Post post) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => PostDetailScreen(post: post),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ExampleScreen(
      title: 'API GET — Detalle',
      description:
          'Patrón maestro-detalle: toca una publicación para ver su contenido '
          'completo y los comentarios asociados. La navegación se maneja '
          'con Navigator.push.',
      code: '''import 'package:http/http.dart' as http;
import 'dart:convert';

// Obtener lista de publicaciones
final response = await http.get(
  Uri.parse(
    'https://jsonplaceholder.typicode.com/posts?_limit=10',
  ),
);

// Navegar al detalle pasando el ID
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => PostDetailScreen(postId: post.id),
  ),
);

// En el detalle, obtener comentarios con el ID
final detailResponse = await http.get(
  Uri.parse(
    'https://jsonplaceholder.typicode.com/posts/\$postId/comments',
  ),
);''',
      child: SizedBox(
        height: 380,
        child: _isLoading
            ? const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Cargando publicaciones...'),
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
                          onPressed: _fetchPosts,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Reintentar'),
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _fetchPosts,
                    child: ListView.builder(
                      itemCount: _posts.length,
                      itemBuilder: (context, index) {
                        final post = _posts[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: CircleAvatar(
                              child: Text('${post.id}'),
                            ),
                            title: Text(
                              post.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: Text(
                              post.body,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () => _openDetail(post),
                          ),
                        );
                      },
                    ),
                  ),
      ),
    );
  }
}

/// Pantalla de detalle para una publicación y sus comentarios.
/// No usa ExampleScreen porque maneja su propia navegación.
class PostDetailScreen extends StatefulWidget {
  const PostDetailScreen({super.key, required this.post});

  final Post post;

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  List<Comment> _comments = [];
  bool _isLoadingComments = true;
  String? _commentsError;

  @override
  void initState() {
    super.initState();
    _fetchComments();
  }

  Future<void> _fetchComments() async {
    setState(() {
      _isLoadingComments = true;
      _commentsError = null;
    });

    try {
      final response = await http.get(
        Uri.parse(
          'https://jsonplaceholder.typicode.com/posts/${widget.post.id}/comments',
        ),
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body);
        setState(() {
          _comments = jsonList.map((json) => Comment.fromJson(json)).toList();
          _isLoadingComments = false;
        });
      } else {
        setState(() {
          _commentsError = 'Error HTTP: ${response.statusCode}';
          _isLoadingComments = false;
        });
      }
    } catch (e) {
      setState(() {
        _commentsError = 'Error de conexión: $e';
        _isLoadingComments = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle de publicación'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Publicación
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Publicación #${widget.post.id}',
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.post.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(widget.post.body),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Comentarios
            Text(
              'Comentarios (${_comments.length})',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),

            if (_isLoadingComments)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (_commentsError != null)
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _commentsError!,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                    const SizedBox(height: 8),
                    FilledButton.icon(
                      onPressed: _fetchComments,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Reintentar'),
                    ),
                  ],
                ),
              )
            else
              ..._comments.map((comment) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    title: Text(comment.name),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          comment.email,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(comment.body),
                      ],
                    ),
                    isThreeLine: true,
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }
}

/// Modelo de dominio para una publicación.
class Post {
  const Post({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
  });

  final int id;
  final int userId;
  final String title;
  final String body;

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'] as int,
      userId: json['userId'] as int,
      title: json['title'] as String,
      body: json['body'] as String,
    );
  }
}

/// Modelo de dominio para un comentario.
class Comment {
  const Comment({
    required this.id,
    required this.postId,
    required this.name,
    required this.email,
    required this.body,
  });

  final int id;
  final int postId;
  final String name;
  final String email;
  final String body;

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'] as int,
      postId: json['postId'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
      body: json['body'] as String,
    );
  }
}
