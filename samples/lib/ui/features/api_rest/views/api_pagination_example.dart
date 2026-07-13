import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:sample_app/ui/core/example_screen.dart';

/// Ejemplo didáctico de paginación infinita (infinite scroll).
///
/// Carga posts de JSONPlaceholder en páginas de 10 elementos.
/// Detecta cuando el usuario llega al final de la lista para cargar más.
/// Se detiene cuando se alcanzan 100 posts.
class ApiPaginationExample extends StatefulWidget {
  const ApiPaginationExample({super.key});

  @override
  State<ApiPaginationExample> createState() => _ApiPaginationExampleState();
}

class _ApiPaginationExampleState extends State<ApiPaginationExample> {
  final List<Post> _posts = [];
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;
  bool _hasMore = true;
  String? _error;
  int _offset = 0;
  static const int _limit = 10;
  static const int _maxPosts = 100;

  @override
  void initState() {
    super.initState();
    _fetchPosts();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !_isLoading &&
        _hasMore) {
      _fetchPosts();
    }
  }

  Future<void> _fetchPosts() async {
    if (_isLoading || !_hasMore) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final url =
          'https://jsonplaceholder.typicode.com/posts?_start=$_offset&_limit=$_limit';
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body);
        final newPosts =
            jsonList.map((json) => Post.fromJson(json)).toList();

        setState(() {
          _posts.addAll(newPosts);
          _offset += newPosts.length;
          _isLoading = false;

          if (_offset >= _maxPosts || newPosts.length < _limit) {
            _hasMore = false;
          }
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

  Future<void> _refresh() async {
    setState(() {
      _posts.clear();
      _offset = 0;
      _hasMore = true;
      _error = null;
    });
    await _fetchPosts();
  }

  @override
  Widget build(BuildContext context) {
    return ExampleScreen(
      title: 'API Pagination',
      description:
          'Este ejemplo carga posts de JSONPlaceholder usando paginación '
          'infinita. Al llegar al final de la lista se solicita la siguiente '
          'página. Se detiene al alcanzar 100 posts.',
      code: '''import 'package:http/http.dart' as http;
import 'dart:convert';

final scrollController = ScrollController();

void onScroll() {
  if (scrollController.position.pixels >=
      scrollController.position.maxScrollExtent - 200) {
    loadMore();
  }
}

Future<void> loadMore() async {
  final url =
    'https://api.example.com/posts?_start=\$offset&_limit=10';
  final response = await http.get(Uri.parse(url));
  final newPosts = jsonDecode(response.body);
  setState(() {
    posts.addAll(newPosts);
    offset += newPosts.length;
  });
}

ListView.builder(
  controller: scrollController,
  itemCount: posts.length + (hasMore ? 1 : 0),
  itemBuilder: (context, index) {
    if (index == posts.length) {
      return Center(child: CircularProgressIndicator());
    }
    return ListTile(title: Text(posts[index].title));
  },
)''',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Posts cargados: ${_posts.length} / $_maxPosts',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 12),
          if (_error != null)
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
          else
            SizedBox(
              height: 380,
              child: RefreshIndicator(
                onRefresh: _refresh,
                child: ListView.builder(
                  controller: _scrollController,
                  itemCount: _posts.length + (_hasMore || _isLoading ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == _posts.length) {
                      return Padding(
                        padding: const EdgeInsets.all(16),
                        child: Center(
                          child: _isLoading
                              ? const Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    CircularProgressIndicator(),
                                    SizedBox(height: 8),
                                    Text('Cargando más...'),
                                  ],
                                )
                              : const Text('No hay más datos'),
                        ),
                      );
                    }

                    final post = _posts[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          child: Text('${post.id}'),
                        ),
                        title: Text(post.title),
                        subtitle: Text(
                          post.body,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    );
                  },
                ),
              ),
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
