import 'package:flutter/foundation.dart';

class HeroesProvider extends ChangeNotifier {
  final List<String> _heroes = [
    'Superman',
    'Batman',
    'Wonder Woman',
    'Flash',
    'Green Lantern',
    'Aquaman',
    'Cyborg',
  ];

  List<String> get heroes => List.unmodifiable(_heroes);

  void addHero(String name) {
    final trimmedName = name.trim();
    if (trimmedName.isEmpty) {
      return;
    }
    _heroes.add(trimmedName);
    notifyListeners();
  }
}
