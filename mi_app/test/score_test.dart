import 'package:flutter_test/flutter_test.dart';
import 'package:mi_app/model/tetris/pile_event.dart';
import 'package:mi_app/model/tetris/score.dart';

void main() {
  test('updates score from line clear events only', () {
    final score = Score();

    score.onPileEvent(const PieceLocked());
    expect(score.points, 0);

    score.onPileEvent(const LinesCleared(1));
    expect(score.points, 100);

    score.onPileEvent(const LinesCleared(2));
    expect(score.points, 500);
  });
}
