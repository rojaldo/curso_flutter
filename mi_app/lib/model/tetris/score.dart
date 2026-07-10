import 'package:mi_app/model/tetris/pile_event.dart';

class Score implements PileObserver {
  int points = 0;

  @override
  void onPileEvent(PileEvent event) {
    if (event is LinesCleared) {
      points += 100 * event.count * event.count;
    }
  }

  void reset() {
    points = 0;
  }
}
