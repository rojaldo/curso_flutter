import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:sample_app/ui/core/example_screen.dart';

/// Ejemplo didáctico de búsqueda con debounce.
///
/// Captura el texto de un campo de búsqueda y espera 500ms sin nuevas
/// pulsaciones antes de realizar la petición HTTP. Muestra un indicador
/// de carga y un estado vacío cuando no hay resultados.
class ApiSearchExample extends StatefulWidget {
  const ApiSearchExample({super.key});

  @override
  State<ApiSearchExample> createState() => _ApiSearchExampleState();
}

class _ApiSearchExampleState extends State<ApiSearchExample> {
  final TextEditingController _controller = TextEditingController();
  Timer? _debounceTimer;
  List<Post> _results = [];
  bool _isSearching = false;
  String? _error;
  bool _hasSearched = false;

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _debounceTimer?.cancel();

    if (query.isEmpty) {
      setState(() {
        _results = [];
        _isSearching = false;
        _hasSearched = false;
        _error = null;
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _hasSearched = false;
      _error = null;
    });

    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      _performSearch(query);
    });
  }

  Future<void> _performSearch(String query) async {
    try {
      final url =
          'https://jsonplaceholder.typicode.com/posts?title_like=$query';
      final response = await http.get(Uri.parse(url));

      if (!mounted) return;

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body);
        setState(() {
          _results = jsonList.map((json) => Post.fromJson(json)).toList();
          _isSearching = false;
          _hasSearched = true;
        });
      } else {
        setState(() {
          _error = 'Error HTTP: ${response.statusCode}';
          _isSearching = false;
          _hasSearched = true;
        });
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error = 'Error de conexión: $e';
        _isSearching = false;
        _hasSearched = true;
      });
    }
  }

  void _clearSearch() {
    _controller.clear();
    _debounceTimer?.cancel();
    setState(() {
      _results = [];
      _isSearching = false;
      _hasSearched = false;
      _error = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ExampleScreen(
      title: 'API Search + Debounce',
      description:
          'Este ejemplo demuestra cómo implementar debounce en una búsqueda '
          'de API. El texto se envía solo después de 500ms sin nuevas '
          'pulsaciones, evitando peticiones innecesarias.',
      code: '''import 'dart:async';
import 'package:http/http.dart' as http;

Timer? _debounceTimer;

void onSearchChanged(String query) {
  _debounceTimer?.cancel();

  _debounceTimer = Timer(
    const Duration(milliseconds: 500),
    () => performSearch(query),
  );
}

Future<void> performSearch(String query) async {
  final url =
    'https://api.example.com/posts?title_like=\$query';
  final response = await http.get(Uri.parse(url));
  final results = jsonDecode(response.body);
  setState(() => _results = results);
}

@override
void dispose() {
  _debounceTimer?.cancel();
  super.dispose();
}''',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _controller,
            decoration: InputDecoration(
              hintText: 'Buscar por título...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _controller.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: _clearSearch,
                    )
                  : null,
              border: const OutlineInputBorder(),
            ),
            onChanged: _onSearchChanged,
          ),
          const SizedBox(height: 12),
          if (_isSearching)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 12),
                    Text('Buscando...'),
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
                ],
              ),
            )
          else if (_hasSearched && _results.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.search_off, size: 48, color: Colors.grey),
                    SizedBox(height: 8),
                    Text(
                      'No se encontraron resultados',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            )
          else if (_results.isNotEmpty)
            SizedBox(
              height: 320,
              child: ListView.builder(
                itemCount: _results.length,
                itemBuilder: (context, index) {
                  final post = _results[index];
                  return Card(
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
                  );
                },
              ),
            )
          else
            const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'Escribe algo para buscar posts',
                  style: TextStyle(color: Colors.grey),
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
