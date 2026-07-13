import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:sample_app/ui/core/example_screen.dart';

/// Ejemplo didáctico de carga de imágenes desde una API.
///
/// Obtiene URLs de imágenes de perros desde dog.ceo y las muestra en
/// un GridView. Usa Image.network con loadingBuilder y errorBuilder
/// para mostrar estados de carga y error. Incluye pull-to-refresh.
class ApiImagesExample extends StatefulWidget {
  const ApiImagesExample({super.key});

  @override
  State<ApiImagesExample> createState() => _ApiImagesExampleState();
}

class _ApiImagesExampleState extends State<ApiImagesExample> {
  List<String> _imageUrls = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchImages();
  }

  Future<void> _fetchImages() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      const url = 'https://dog.ceo/api/breed/hound/images';
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        if (data['status'] == 'success') {
          final List<dynamic> messages = data['message'];
          setState(() {
            _imageUrls = messages.cast<String>();
            _isLoading = false;
          });
        } else {
          setState(() {
            _error = 'Error en la respuesta de la API';
            _isLoading = false;
          });
        }
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

  @override
  Widget build(BuildContext context) {
    return ExampleScreen(
      title: 'API Image Loading',
      description:
          'Este ejemplo carga imágenes de perros desde dog.ceo y las muestra '
          'en un GridView. Se utiliza Image.network con loadingBuilder y '
          'errorBuilder para gestionar la carga y los errores de imagen.',
      code: '''import 'package:http/http.dart' as http;
import 'dart:convert';

// Obtener lista de imágenes
final response = await http.get(
  Uri.parse('https://dog.ceo/api/breed/hound/images'),
);
final data = jsonDecode(response.body);
final urls = data['message'];

// Mostrar imagen con loading y error
Image.network(
  url,
  loadingBuilder: (context, child, progress) {
    if (progress == null) return child;
    return Center(child: CircularProgressIndicator());
  },
  errorBuilder: (context, error, stackTrace) {
    return Center(
      child: Icon(Icons.broken_image, color: Colors.grey),
    );
  },
)''',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Imágenes cargadas: ${_imageUrls.length}',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 12),
          if (_isLoading)
            const SizedBox(
              height: 300,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Cargando imágenes...'),
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
                    onPressed: _fetchImages,
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
                onRefresh: _fetchImages,
                child: GridView.builder(
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: _imageUrls.length,
                  itemBuilder: (context, index) {
                    final url = _imageUrls[index];
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        url,
                        fit: BoxFit.cover,
                        loadingBuilder: (
                          context,
                          child,
                          loadingProgress,
                        ) {
                          if (loadingProgress == null) return child;
                          return Container(
                            color: Colors.grey.shade200,
                            child: const Center(
                              child: CircularProgressIndicator(),
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey.shade300,
                            child: const Icon(
                              Icons.broken_image,
                              color: Colors.grey,
                              size: 32,
                            ),
                          );
                        },
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
