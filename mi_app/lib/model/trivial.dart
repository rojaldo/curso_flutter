class Trivial {
  String _type = '';
  String _difficulty = '';
  String _question = '';
  String _category = '';
  String _correctAnswer = '';
  List<String> _incorrectAnswers = [];
  List<String> _allAnswers = [];
  bool _responded = false;
  bool _rightAnswered = false;

  Trivial({
    required String type,
    required String difficulty,
    required String question,
    required String correctAnswer,
    required String category,
    required List<String> incorrectAnswers,
  }) {
    _type = type;
    _difficulty = difficulty;
    _question = question;
    _correctAnswer = correctAnswer;
    _category = category;
    _incorrectAnswers = incorrectAnswers;
    _allAnswers = [correctAnswer, ...incorrectAnswers]..shuffle();
  }

  Trivial.fromJson(Map<String, dynamic> json) {
    _type = json['type'] ?? '';
    _difficulty = json['difficulty'] ?? '';
    _question = _decode(json['question'] ?? '');
    _correctAnswer = _decode(json['correct_answer'] ?? '');
    _category = _decode(json['category'] ?? '');
    _incorrectAnswers =
        (json['incorrect_answers'] as List? ?? [])
            .map((e) => _decode(e.toString()))
            .toList();
    _allAnswers = [_correctAnswer, ..._incorrectAnswers]..shuffle();
  }

  String get type => _type;
  String get difficulty => _difficulty;
  String get question => _question;
  String get category => _category;
  String get correctAnswer => _correctAnswer;
  List<String> get allAnswers => List.unmodifiable(_allAnswers);
  bool get responded => _responded;
  bool get rightAnswered => _rightAnswered;

  /// Marca la respuesta elegida. Devuelve true si era correcta.
  bool respond(String answer) {
    if (_responded) return false;
    _responded = true;
    _rightAnswered = answer == _correctAnswer;
    return _rightAnswered;
  }

  bool isCorrect(String answer) => answer == _correctAnswer;

  String _decode(String s) {
    return s
        .replaceAll('&amp;', '&')
        .replaceAll('&quot;', '"')
        .replaceAll('&#039;', "'")
        .replaceAll('&rsquo;', "'")
        .replaceAll('&lsquo;', "'")
        .replaceAll('&ldquo;', '"')
        .replaceAll('&rdquo;', '"')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&ntilde;', 'ñ')
        .replaceAll('&eacute;', 'é')
        .replaceAll('&iacute;', 'í')
        .replaceAll('&oacute;', 'ó')
        .replaceAll('&uacute;', 'ú')
        .replaceAll('&aacute;', 'á')
        .replaceAll('&ntilde;', 'ñ')
        .replaceAllMapped(
          RegExp(r'&#(\d+);'),
          (m) => String.fromCharCode(int.parse(m.group(1)!)),
        );
  }

  Map<String, dynamic> toJson() => {
    'type': _type,
    'difficulty': _difficulty,
    'question': _question,
    'correct_answer': _correctAnswer,
    'category': _category,
    'incorrect_answers': _incorrectAnswers,
  };
}