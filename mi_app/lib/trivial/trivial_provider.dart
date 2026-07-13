import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:mi_app/model/trivial.dart';
import 'package:mi_app/trivial/trivial_supabase_service.dart';

class TrivialProvider extends ChangeNotifier {
  static const _url = 'https://opentdb.com/api.php?amount=10&type=multiple';

  /// Páginas: cada página es una tanda de 10 preguntas de la API.
  /// El PagingController consume esta lista de listas.
  final List<List<Trivial>> _pages = [];
  bool _loading = false;
  String? _error;
  int _score = 0;
  Future<List<Trivial>>? _inflight;

  static const _correctPoints = 2;
  static const _wrongPoints = -1;

  List<List<Trivial>> get pages => List.unmodifiable(_pages);
  List<Trivial> get allQuestions =>
      _pages.expand((page) => page).toList(growable: false);
  bool get loading => _loading;
  String? get error => _error;
  int get score => _score;

  bool get _hasUnanswered => allQuestions.any((q) => !q.responded);

  /// Al entrar a la pantalla: reusa cache si hay preguntas sin contestar.
  /// Si no hay nada O todo está contestado, descarga más (append).
  Future<void> ensureLoaded() async {
    if (_hasUnanswered) return;
    await _fetchPage();
  }

  /// Devuelve la página [pageKey] desde cache si existe; si no, descarga.
  /// Llamado por el PagingController.
  Future<List<Trivial>> fetchPage(int pageKey) async {
    if (pageKey < _pages.length) return _pages[pageKey];
    return _fetchPage();
  }

  Future<List<Trivial>> _fetchPage() async {
    // Serializa peticiones concurrentes: si ya hay una en vuelo,
    // espera su resultado en vez de devolver [] (lo que mataría la paginación).
    if (_inflight != null) return _inflight!;
    final completer = Completer<List<Trivial>>();
    _inflight = completer.future;
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final response = await http.get(Uri.parse(_url));
      if (response.statusCode != 200) {
        throw Exception('HTTP ${response.statusCode}');
      }
      final body = json.decode(response.body) as Map<String, dynamic>;
      final results = (body['results'] as List? ?? [])
          .map((e) => Trivial.fromJson(e as Map<String, dynamic>))
          .toList();
      _pages.add(results);
      completer.complete(results);
      return results;
    } catch (e) {
      _error = e.toString();
      completer.complete(const []);
      return const [];
    } finally {
      _inflight = null;
      _loading = false;
      notifyListeners();
    }
  }

  /// Recarga desde cero (botón refresh).
  Future<void> refresh() async {
    _pages.clear();
    _score = 0;
    notifyListeners();
    await _fetchPage();
  }

  /// Responde por índice lineal (el que da el PagingController). Devuelve
  /// true si fue correcta.
  bool respondByIndex(int globalIndex, String answer) {
    int offset = 0;
    for (final page in _pages) {
      if (globalIndex < offset + page.length) {
        return _respond(page[globalIndex - offset], answer);
      }
      offset += page.length;
    }
    return false;
  }

  bool _respond(Trivial q, String answer) {
    if (q.responded) return q.rightAnswered;
    final correct = q.respond(answer);
    _score += correct ? _correctPoints : _wrongPoints;
    notifyListeners();
    // Auto-refill: si no queda ninguna sin contestar, trae más.
    if (!_hasUnanswered) {
      _fetchPage();
    }
    return correct;
  }

  // --- Persistencia en Supabase ---

  /// Serializa todo el estado (preguntas + score) para guardar en Supabase.
  List<Map<String, dynamic>> toSavedState() =>
      allQuestions.map((q) => q.toMap()).toList();

  /// Restaura el estado desde Supabase. Reemplaza todo lo actual.
  void loadFromSavedState(int score, List<Map<String, dynamic>> data) {
    _pages.clear();
    if (data.isNotEmpty) {
      // Reconstruye páginas agrupando de 10 en 10 (tamaño de página de la API).
      for (int i = 0; i < data.length; i += 10) {
        _pages.add(
          data
              .sublist(i, (i + 10).clamp(0, data.length))
              .map((m) => Trivial.fromMap(m))
              .toList(),
        );
      }
    }
    _score = score;
    notifyListeners();
  }

  /// Sube el estado actual a Supabase. Lanza si no hay sesión.
  Future<void> saveToSupabase() async {
    await TrivialSupabaseService.saveState(_score, toSavedState());
  }
}