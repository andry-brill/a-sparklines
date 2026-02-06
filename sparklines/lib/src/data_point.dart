import 'dart:ui' show lerpDouble;
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
