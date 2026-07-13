import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart' show ClientException;
import 'package:sample_app/ui/core/example_screen.dart';

/// Ejemplo didáctico de manejo de errores HTTP.
///
/// Permite simular distintos escenarios de error: timeout,
/// respuesta 404, respuesta 500 y host inexistente (sin red).
/// Muestra mensajes amigables con iconos y un botón de reintentar.
class ApiErrorsExample extends StatefulWidget {
  const ApiErrorsExample({super.key});

  @override
  State<ApiErrorsExample> createState() => _ApiErrorsExampleState();
}

class _ApiErrorsExampleState extends State<ApiErrorsExample> {
  String? _errorMessage;
  String? _errorType;
  bool _isLoading = false;

  Future<void> _simulateTimeout() async {
    _clearError();
    setState(() => _isLoading = true);

    try {
      final response = await http
          .get(Uri.parse('https://httpbin.org/delay/10'))
          .timeout(const Duration(seconds: 3));

      if (!mounted) return;
      setState(() => _isLoading = false);

      if (response.statusCode != 200) {
        _showError('HTTP ${response.statusCode}', 'timeout');
      }
    } on TimeoutException catch (_) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _showError(
        'La petición tardó demasiado. Intenta de nuevo más tarde.',
        'timeout',
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _showError('Error inesperado: $e', 'timeout');
    }
  }

  Future<void> _simulate404() async {
    _clearError();
    setState(() => _isLoading = true);

    try {
      final response = await http.get(
        Uri.parse('https://httpbin.org/status/404'),
      );

      if (!mounted) return;
      setState(() => _isLoading = false);

      if (response.statusCode == 404) {
        _showError(
          'Recurso no encontrado (404). El endpoint no existe.',
          'not_found',
        );
      } else if (response.statusCode != 200) {
        _showError('HTTP ${response.statusCode}', 'not_found');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _showError('Error de red: $e', 'not_found');
    }
  }

  Future<void> _simulate500() async {
    _clearError();
    setState(() => _isLoading = true);

    try {
      final response = await http.get(
        Uri.parse('https://httpbin.org/status/500'),
      );

      if (!mounted) return;
      setState(() => _isLoading = false);

      if (response.statusCode == 500) {
        _showError(
          'Error interno del servidor (500). Inténtalo más tarde.',
          'server_error',
        );
      } else if (response.statusCode != 200) {
        _showError('HTTP ${response.statusCode}', 'server_error');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _showError('Error de red: $e', 'server_error');
    }
  }

  Future<void> _simulateNoNetwork() async {
    _clearError();
    setState(() => _isLoading = true);

    try {
      await http.get(
        Uri.parse('https://this-host-does-not-exist-12345.fake'),
      );

      if (!mounted) return;
      setState(() => _isLoading = false);
    } on SocketException catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _showError(
        'Sin conexión a Internet. Verifica tu red.\n(${e.message})',
        'no_network',
      );
    } on ClientException catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _showError(
        'No se pudo conectar al servidor.\n(${e.message})',
        'no_network',
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _showError('Error de red: $e', 'no_network');
    }
  }

  void _showError(String message, String type) {
    setState(() {
      _errorMessage = message;
      _errorType = type;
    });
  }

  void _clearError() {
    setState(() {
      _errorMessage = null;
      _errorType = null;
    });
  }

  IconData _getErrorIcon() {
    switch (_errorType) {
      case 'timeout':
        return Icons.timer_off;
      case 'not_found':
        return Icons.search_off;
      case 'server_error':
        return Icons.cloud_off;
      case 'no_network':
        return Icons.signal_wifi_off;
      default:
        return Icons.error_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ExampleScreen(
      title: 'API Error Handling',
      description:
          'Este ejemplo simula distintos errores de red y HTTP. '
          'Muestra cómo clasificar excepciones (TimeoutException, '
          'SocketException, HttpException) y mostrar mensajes amigables.',
      code: '''import 'dart:io';
import 'package:http/http.dart' show ClientException;

try {
  final response = await http.get(url)
      .timeout(Duration(seconds: 3));

  if (response.statusCode != 200) {
    throw HttpException('HTTP \${response.statusCode}');
  }
} on TimeoutException catch (_) {
  // La petición excedió el tiempo límite
  showError('Tiempo de espera agotado');
} on SocketException catch (e) {
  // Sin conexión a Internet
  showError('Sin conexión: \${e.message}');
} on ClientException catch (e) {
  // Error del cliente HTTP
  showError('Error de red: \${e.message}');
} catch (e) {
  // Error inesperado
  showError('Error: \$e');
}''',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _simulateTimeout,
                icon: const Icon(Icons.timer_off),
                label: const Text('Timeout'),
              ),
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _simulate404,
                icon: const Icon(Icons.search_off),
                label: const Text('404 Not Found'),
              ),
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _simulate500,
                icon: const Icon(Icons.cloud_off),
                label: const Text('500 Server Error'),
              ),
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _simulateNoNetwork,
                icon: const Icon(Icons.signal_wifi_off),
                label: const Text('Sin red'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 12),
                    Text('Enviando petición...'),
                  ],
                ),
              ),
            )
          else if (_errorMessage != null)
            Center(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .errorContainer
                      .withAlpha((0.3 * 255).toInt()),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _getErrorIcon(),
                      size: 48,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _errorMessage!,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 12),
                    FilledButton.icon(
                      onPressed: _clearError,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Reintentar'),
                    ),
                  ],
                ),
              ),
            )
          else
            const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'Pulsa un botón para simular un escenario de error',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
