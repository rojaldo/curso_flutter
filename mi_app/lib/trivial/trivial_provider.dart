import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:mi_app/model/trivial.dart';

class TrivialProvider extends ChangeNotifier {
  static const _url = 'https://opentdb.com/api.php?amount=10&type=multiple';

  final List<Trivial> _questions = [];
  bool _loading = false;
  String? _error;

  List<Trivial> get questions => List.unmodifiable(_questions);
  bool get loading => _loading;
  String? get error => _error;

  Future<void> fetch() async {
    _loading = true;
    _error = null;
    _questions.clear();
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
      _questions.addAll(results);
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  void respond(int index, String answer) {
    if (index < 0 || index >= _questions.length) return;
    _questions[index].respond(answer);
    notifyListeners();
  }

  int get score => _questions.where((q) => q.rightAnswered).length;
}