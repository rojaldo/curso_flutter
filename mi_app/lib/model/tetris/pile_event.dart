sealed class PileEvent {
  const PileEvent();
}

class PieceLocked extends PileEvent {
  const PieceLocked();
}

class LinesCleared extends PileEvent {
  const LinesCleared(this.count);

  final int count;
}

abstract class PileObserver {
  void onPileEvent(PileEvent event);
}
