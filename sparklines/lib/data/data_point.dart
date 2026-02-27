import 'dart:ui' show lerpDouble;
import 'dart:math' as math;

import '../interfaces/data_point_style.dart';
import '../interfaces/lerp.dart';
import '../interfaces/thickness.dart';

/// A single data point with x, y coordinates and optional style
class DataPoint implements ILerpTo<DataPoint> {

  /// Offset by X
  final double x;

  /// Mainly used as offset of x in pie chart
  final double? dx;

  /// Offset by Y
  final double y;

  /// Value
  final double dy;

  /// Full Y (y + dy)
  final double fy;

  final IDataPointStyle? style;

  final ThicknessOverride? thickness;

  const DataPoint({
    required this.x,
    this.dx,
    this.y = 0.0,
    required this.dy,
    this.style,
    this.thickness,
  }) : fy = y + dy;

  DataPoint copyWith({
    double? x,
    double? dx,
    double? y,
    double? dy,
    IDataPointStyle? style,
    ThicknessOverride? thickness,
  }) => DataPoint(
    x: x ?? this.x,
    y: y ?? this.y,
    dy: dy ?? this.dy,
    dx: dx ?? this.dx,
    style: style ?? this.style,
    thickness: thickness ?? this.thickness,
  );

  @override
  DataPoint lerpTo(DataPoint next, double t) {
    return DataPoint(
      x: lerpDouble(x, next.x, t) ?? next.x,
      dx: lerpDouble(dx, next.dx, t) ?? next.dx,
      y: lerpDouble(y, next.y, t) ?? next.y,
      dy: lerpDouble(dy, next.dy, t) ?? next.dy,
      style: ILerpTo.lerp(style, next.style, t),
      thickness: ILerpTo.lerp(thickness, next.thickness, t),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! DataPoint) return false;
    return this.y == other.y && this.x == other.x && this.dy == other.dy && this.dx == other.dx &&
      this.thickness == other.thickness && this.style == other.style;
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
