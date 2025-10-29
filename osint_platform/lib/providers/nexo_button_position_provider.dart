import 'package:flutter_riverpod/flutter_riverpod.dart';

class NexoButtonPosition {
  final double x;
  final double y;

  const NexoButtonPosition({required this.x, required this.y});

  NexoButtonPosition copyWith({double? x, double? y}) {
    return NexoButtonPosition(
      x: x ?? this.x,
      y: y ?? this.y,
    );
  }
}

class NexoButtonPositionNotifier extends StateNotifier<NexoButtonPosition> {
  NexoButtonPositionNotifier() : super(const NexoButtonPosition(x: 16, y: 16));

  void updatePosition(double x, double y) {
    state = NexoButtonPosition(x: x, y: y);
  }
}

final nexoButtonPositionProvider =
    StateNotifierProvider<NexoButtonPositionNotifier, NexoButtonPosition>(
  (ref) => NexoButtonPositionNotifier(),
);
