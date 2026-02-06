import 'dart:ui' show lerpDouble;
import 'dart:math' as math;
import 'interfaces.dart';

/// A single data point with x, y coordinates and optional style
class DataPoint implements ILerpable<DataPoint> {
  final double x;
  final double y;
  final IDataPointStyle? style;

  const DataPoint({
    required this.x,
    required this.y,
    this.style,
  });

  @override
  DataPoint lerpTo(DataPoint next, double t) {
    IDataPointStyle? interpolatedStyle;
    if (style != null && next.style != null) {
      interpolatedStyle = style!.lerpTo(next.style!, t);
    } else {
      interpolatedStyle = next.style;
    }

    return DataPoint(
      x: lerpDouble(x, next.x, t) ?? next.x,
      y: lerpDouble(y, next.y, t) ?? next.y,
      style: interpolatedStyle,
    );
  }
}

/// Extension on Iterable<DataPoint> for calculating bounds
extension DataPointBounds on Iterable<DataPoint> {
  /// Minimum X coordinate
  double get minX {
    if (isEmpty) return 0.0;
    return map((p) => p.x).reduce((a, b) => math.min(a, b));
  }

  /// Maximum X coordinate
  double get maxX {
    if (isEmpty) return 1.0;
    return map((p) => p.x).reduce((a, b) => math.max(a, b));
  }

  /// Minimum Y coordinate
  double get minY {
    if (isEmpty) return 0.0;
    return map((p) => p.y).reduce((a, b) => math.min(a, b));
  }

  /// Maximum Y coordinate
  double get maxY {
    if (isEmpty) return 1.0;
    return map((p) => p.y).reduce((a, b) => math.max(a, b));
  }
}
