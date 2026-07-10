import 'package:flutter_test/flutter_test.dart';
import 'package:mi_app/heroes/heroes_provider.dart';

void main() {
  test('keeps the heroes list in provider state', () {
    final provider = HeroesProvider();

    provider.addHero('Spider-Man');

    expect(provider.heroes, contains('Spider-Man'));
  });

  test('ignores blank hero names', () {
    final provider = HeroesProvider();
    final initialLength = provider.heroes.length;

    provider.addHero('   ');

    expect(provider.heroes, hasLength(initialLength));
  });
}
