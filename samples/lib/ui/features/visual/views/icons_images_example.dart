import 'package:flutter/material.dart';
import 'package:sample_app/ui/core/example_screen.dart';

/// Ejemplo didáctico de Iconos e Imágenes en Flutter.
///
/// Muestra una cuadrícula de iconos de Material, carga de imágenes
/// desde la red, FadeInImage para transiciones suaves y manejo de errores.
class IconsImagesExample extends StatefulWidget {
  const IconsImagesExample({super.key});

  @override
  State<IconsImagesExample> createState() => _IconsImagesExampleState();
}

class _IconsImagesExampleState extends State<IconsImagesExample> {
  bool _showErrorImage = false;

  final List<Map<String, dynamic>> _icons = const [
    {'icon': Icons.home, 'name': 'home'},
    {'icon': Icons.favorite, 'name': 'favorite'},
    {'icon': Icons.settings, 'name': 'settings'},
    {'icon': Icons.search, 'name': 'search'},
    {'icon': Icons.person, 'name': 'person'},
    {'icon': Icons.notifications, 'name': 'notifications'},
    {'icon': Icons.camera_alt, 'name': 'camera_alt'},
    {'icon': Icons.music_note, 'name': 'music_note'},
    {'icon': Icons.map, 'name': 'map'},
    {'icon': Icons.phone, 'name': 'phone'},
    {'icon': Icons.email, 'name': 'email'},
    {'icon': Icons.shopping_cart, 'name': 'shopping_cart'},
  ];

  String get _imageUrl =>
      'https://picsum.photos/seed/flutter_demo/300/200';

  String get _errorUrl => 'https://picsum.photos/invalid_url';

  @override
  Widget build(BuildContext context) {
    return ExampleScreen(
      title: 'Iconos e Imágenes',
      description:
          'Flutter incluye cientos de iconos de Material Design a través '
          'de la clase Icons. Para imágenes de red, usa Image.network, '
          'FadeInImage para una carga suave, y errorBuilder para manejar fallos.',
      code: '''// Icono de Material Design
Icon(Icons.favorite, color: Colors.red, size: 48)

// Imagen desde red
Image.network('https://example.com/photo.jpg')

// Carga suave con placeholder
FadeInImage.assetNetwork(
  placeholder: 'assets/loading.gif',
  image: 'https://example.com/photo.jpg',
  fit: BoxFit.cover,
)

// Manejo de errores
Image.network(
  'https://example.com/photo.jpg',
  errorBuilder: (context, error, stackTrace) {
    return Icon(Icons.broken_image, size: 64);
  },
)''',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Grid de iconos
          _SectionTitle('Iconos de Material'),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            alignment: WrapAlignment.center,
            children: _icons.map((item) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    item['icon'] as IconData,
                    size: 32,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item['name'] as String,
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                ],
              );
            }).toList(),
          ),
          const Divider(height: 32),

          // Imagen de red
          _SectionTitle('Image.network'),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              _showErrorImage ? _errorUrl : _imageUrl,
              height: 160,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 160,
                  color: Colors.grey.shade200,
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.broken_image, size: 48, color: Colors.grey),
                      SizedBox(height: 8),
                      Text('Error al cargar la imagen'),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FilledButton.icon(
                onPressed: () => setState(() => _showErrorImage = false),
                icon: const Icon(Icons.check_circle),
                label: const Text('URL válida'),
              ),
              const SizedBox(width: 8),
              OutlinedButton.icon(
                onPressed: () => setState(() => _showErrorImage = true),
                icon: const Icon(Icons.error_outline),
                label: const Text('URL inválida'),
              ),
            ],
          ),
          const Divider(height: 32),

          // FadeInImage
          _SectionTitle('FadeInImage (carga suave)'),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: FadeInImage(
              placeholder: Container(
                height: 160,
                color: Colors.grey.shade300,
                child: const Center(child: CircularProgressIndicator()),
              ) as ImageProvider,
              image: NetworkImage(_imageUrl),
              height: 160,
              width: double.infinity,
              fit: BoxFit.cover,
              imageErrorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 160,
                  color: Colors.grey.shade200,
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.broken_image, size: 48, color: Colors.grey),
                      SizedBox(height: 8),
                      Text('Error al cargar'),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        text,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }
}
