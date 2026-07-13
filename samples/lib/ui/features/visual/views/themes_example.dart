import 'package:flutter/material.dart';
import 'package:sample_app/ui/core/example_screen.dart';

/// Ejemplo didáctico de Themes en Flutter.
///
/// Muestra los colores del ThemeData actual, permite alternar
/// entre tema claro y oscuro, y presenta los estilos de TextTheme.
class ThemesExample extends StatefulWidget {
  const ThemesExample({super.key});

  @override
  State<ThemesExample> createState() => _ThemesExampleState();
}

class _ThemesExampleState extends State<ThemesExample> {
  bool _isDark = false;

  ThemeData get _theme => _isDark ? ThemeData.dark() : ThemeData.light();

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: _theme,
      child: Builder(
        builder: (context) {
          final theme = Theme.of(context);
          final cs = theme.colorScheme;

          return ExampleScreen(
            title: 'Themes',
            description:
                'ThemeData define la paleta de colores, tipografía y formas '
                'de toda la aplicación. Usa colorScheme para colores semánticos '
                'y textTheme para estilos de texto.',
            code: '''ThemeData(
  colorScheme: ColorScheme.fromSeed(
    seedColor: Colors.indigo,
    brightness: Brightness.light,
  ),
  textTheme: TextTheme(
    headlineLarge: TextStyle(
      fontSize: 32,
      fontWeight: FontWeight.bold,
    ),
    bodyLarge: TextStyle(fontSize: 16),
    labelSmall: TextStyle(fontSize: 11),
  ),
)

// Alternar tema
setState(() => _isDark = !_isDark);

// Acceder al tema actual
final color = Theme.of(context).colorScheme.primary;
final style = Theme.of(context).textTheme.bodyLarge;''',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Toggle de tema
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.wb_sunny),
                    const SizedBox(width: 8),
                    Switch(
                      value: _isDark,
                      onChanged: (value) => setState(() => _isDark = value),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.nights_stay),
                    const SizedBox(width: 8),
                    Text(_isDark ? 'Oscuro' : 'Claro'),
                  ],
                ),
                const SizedBox(height: 16),

                // Paleta de colores
                _SectionTitle('ColorScheme'),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _ColorChip('primary', cs.primary, cs.onPrimary),
                    _ColorChip('secondary', cs.secondary, cs.onSecondary),
                    _ColorChip('surface', cs.surface, cs.onSurface),
                    _ColorChip('error', cs.error, cs.onError),
                    _ColorChip('outline', cs.outline, cs.onSurface),
                  ],
                ),
                const SizedBox(height: 16),

                // TextTheme
                _SectionTitle('TextTheme'),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: cs.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('headlineLarge', style: theme.textTheme.headlineLarge),
                      Text('headlineMedium', style: theme.textTheme.headlineMedium),
                      Text('headlineSmall', style: theme.textTheme.headlineSmall),
                      const Divider(),
                      Text('bodyLarge', style: theme.textTheme.bodyLarge),
                      Text('bodyMedium', style: theme.textTheme.bodyMedium),
                      Text('bodySmall', style: theme.textTheme.bodySmall),
                      const Divider(),
                      Text('labelLarge', style: theme.textTheme.labelLarge),
                      Text('labelMedium', style: theme.textTheme.labelMedium),
                      Text('labelSmall', style: theme.textTheme.labelSmall),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Botones con el tema actual
                _SectionTitle('Componentes del tema'),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    FilledButton(
                      onPressed: () {},
                      child: const Text('Filled'),
                    ),
                    ElevatedButton(
                      onPressed: () {},
                      child: const Text('Elevated'),
                    ),
                    OutlinedButton(
                      onPressed: () {},
                      child: const Text('Outlined'),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
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
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }
}

class _ColorChip extends StatelessWidget {
  const _ColorChip(this.label, this.color, this.onColor);

  final String label;
  final Color color;
  final Color onColor;

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: CircleAvatar(
        backgroundColor: color,
        radius: 10,
      ),
      label: Text(
        label,
        style: TextStyle(color: onColor, fontSize: 12),
      ),
      backgroundColor: color.withAlpha(204),
    );
  }
}
