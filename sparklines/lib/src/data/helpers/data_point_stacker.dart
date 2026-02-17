import '../data_point.dart';

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
/// TODO normalizer
///  TODO  (min: -pi, center: 0, max: +pi), => equally split negative in [-pi, 0], positive in [0, pi]
///  TODO normalizer (min: 0, center: 0, max: 2*pi) => negative will be ignored
///  TODO (min: 0, center: null, positive: 2*pi), => total = sum(positive + abs(negative)) => negative = abs(negative)/total * 2*pi
///
/// TODO lazy read-only list (will calculate values on first access to apply normalizer)
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
      result.add(DataPoint(x: p.x, y: base, dy: p.dy, style: p.style, thickness: p.thickness));
      _cumulativeByX[p.x] = base + p.dy;
    }

    return result;
  }

  /// Resets the stacker so the next [stack] call starts from zero.
  void reset() {
    _cumulativeByX.clear();
  }
}
