import 'dart:ui' show lerpDouble;
import 'dart:math' as math;

import 'package:sparklines/src/interfaces.dart';

/// A single data point with x, y coordinates and optional style
class DataPoint implements ILerpTo<DataPoint> {

  final double x;
  final double y;

  /// Value (offset by y)
  final double dy;

  /// Full Y
  final double fy;

  final IDataPointStyle? style;

  const DataPoint({
    required this.x,
    this.y = 0.0,
    required this.dy,
    this.style,
  }) : fy = y + dy;

  const DataPoint.value(this.x, double value, {
    this.y = 0.0,
    this.style,
  }) : dy = value, fy = y + value;

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
      dy: lerpDouble(dy, next.dy, t) ?? next.dy,
      style: interpolatedStyle,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! DataPoint) return false;
    return this.y == other.y && this.x == other.x && this.dy == other.dy;
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

  /// Minimum Y coordinate (includes both offset y and final fy for correct bar/line bounds)
  double get minY {
    if (isEmpty) return 0.0;
    return map((p) => math.min(p.y, p.fy)).reduce((a, b) => math.min(a, b));
  }

  /// Maximum Y coordinate (includes both offset y and final fy for correct bar/line bounds)
  double get maxY {
    if (isEmpty) return 1.0;
    return map((p) => math.max(p.y, p.fy)).reduce((a, b) => math.max(a, b));
  }
}
