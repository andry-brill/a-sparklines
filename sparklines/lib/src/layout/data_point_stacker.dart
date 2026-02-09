import '../data/data_point.dart';

/// Stacks datapoints by x, adjusting y so each successive series stacks on top.
///
/// Usage:
/// ```dart
/// final stacker = DapaPointStacker();
/// line1.points = stacker.stack([...]);
/// line2.points = stacker.stack([...]);  // stacks over line1
/// line3.points = stacker.stack([...]);  // stacks over line1 & line2
/// ```
///
/// Each point's [DataPoint.dy] is the value to stack. The stacker maintains
/// cumulative y per x across calls, so line2 bases on line1, line3 on line1+line2.
class DataPointStacker {

  /// Cumulative (y + dy) at each x from previous stack() calls.
  final Map<double, double> _cumulativeByX = {};

  /// Stacks [points] on top of all previously stacked points.
  ///
  /// Returns new points with [DataPoint.y] set to the cumulative base at each x,
  /// and [DataPoint.dy] unchanged (the value for this series).
  List<DataPoint> stack(List<DataPoint> points) {

    final result = <DataPoint>[];

    for (final p in points) {
      final base = _cumulativeByX[p.x] ?? 0.0;
      result.add(DataPoint(x: p.x, y: base, dy: p.dy, style: p.style));
      _cumulativeByX[p.x] = base + p.dy;
    }

    return result;
  }

  /// Resets the stacker so the next [stack] call starts from zero.
  void reset() {
    _cumulativeByX.clear();
  }
}
