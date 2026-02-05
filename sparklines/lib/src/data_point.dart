import 'interfaces.dart';

/// A single data point with x, y coordinates and optional style
class DataPoint {
  final double x;
  final double y;
  final IDataPointStyle? style;

  const DataPoint({
    required this.x,
    required this.y,
    this.style,
  });
}
