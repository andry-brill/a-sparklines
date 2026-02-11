import 'dart:math';

import 'package:flutter/material.dart';
import 'package:sparklines/src/data/data_point.dart';
import 'dart:ui' show lerpDouble;
import 'package:vector_math/vector_math_64.dart';

/// Interface for types that can be interpolated
abstract class ILerpTo<T> {
  /// Interpolate between this and [next] using interpolation factor [t] (0.0 to 1.0)
  T lerpTo(T next, double t);

  static L? lerp<L extends ILerpTo<L>>(L? from, L? to, double t) {
    return from != null && to != null ? from.lerpTo(to, t) : to;
  }
}

class ThicknessData implements ILerpTo<ThicknessData> {

  final double size;

  /// Gradient has higher priority if set then color
  final Gradient? gradient;

  final Color color;

  final double align;

  const ThicknessData({
    required this.size,
    this.color = const Color(0xFF000000),
    this.gradient,
    this.align = alignCenter
  });

  static const double alignInside = -1.0;
  static const double alignCenter = 0.0;
  static const double alignOutside = 1.0;

  @override
  ThicknessData lerpTo(ThicknessData next, double t) {
    return ThicknessData(
      size: lerpDouble(size, next.size, t) ?? next.size,
      color: Color.lerp(color, next.color, t) ?? next.color,
      gradient: Gradient.lerp(gradient, next.gradient, t) ?? next.gradient,
      align: lerpDouble(align, next.align, t) ?? next.align,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ThicknessData) return false;
    return size == other.size &&
        color == other.color &&
        gradient == other.gradient &&
        align == other.align;
  }

  static ThicknessData? lerp(ThicknessData? a, ThicknessData? b, double t) {
    if (a == null && b == null) return null;
    if (a == null) return b;
    if (b == null) return a;
    return a.lerpTo(b, t);
  }
}

abstract class IChartThickness {
  ThicknessData get thickness;
}

abstract class IChartDataPointStyle {
  IDataPointStyle? get pointStyle;
}

abstract class IChartBorder {
  ThicknessData? get border;
  double? get borderRadius;
}

/// Chart rotation: 0°, 90°, 180°, 270° (clockwise). For d90 and d270 the chart
/// is laid out with width and height swapped so it fills the bounds when rotated.
enum ChartRotation {

  d0,
  d90,
  d180,
  d270;

  double get angle => switch (this) {
    d0 => 0.0,
    d90 => pi/2,
    d180 => pi,
    d270 => 3 * pi / 2
  };
}

/// Interface for layout dimensions
abstract class ILayoutData {
  double get minX;
  double get maxX;
  double get minY;
  double get maxY;
  double get width;
  double get height;
}

/// Context passed to chart renderers (replaces per-point coordinate transformation).
class ChartRenderContext {

  final Canvas canvas;
  final Matrix4 pathTransform;
  final IChartLayout layout;
  final ILayoutData dimensions;

  const ChartRenderContext({
    required this.layout,
    required this.dimensions,
    required this.pathTransform,
    required this.canvas,
  });

  /// Bounds rect (0, 0, width, height) for shaders and clipping
  Rect get bounds => Rect.fromLTWH(0, 0, dimensions.width, dimensions.height);

  /// Convert a length to screen pixels (for stroke width, radius, etc.).
  /// Use [relativeTo] for values relative to chart width/height (e.g. RelativeLayout).
  double toScreenLength(double value) {
    return layout.toScreenLength(value, dimensions);
  }

  Offset transform(DataPoint dataPoint) {
    Vector3 point = Vector3(dataPoint.x, dataPoint.fy, 0.0);
    point = pathTransform.transform3(point);
    return Offset(point.x, point.y);
  }
  
  void drawCircle(DataPoint dataPoint, double radius, Paint paint) {
    canvas.drawCircle(transform(dataPoint), radius, paint);
  }

  void drawPath(Path path, Paint paint) {
    final tPath = path.transform(pathTransform.storage);
    canvas.drawPath(tPath, paint);
  }

  void drawRRect(RRect rect, Paint paint) {
    drawPath(Path()..addRRect(rect), paint);
  }

  void drawRect(Rect rect, Paint paint) {
    drawPath(Path()..addRect(rect), paint);
  }
}

/// Chart layout interface: applies canvas transformation so drawing uses data coordinates.
abstract class IChartLayout {
  /// Resolve layout with actual dimensions (e.g., resolve infinity values).
  IChartLayout resolve(List<ILayoutData> dimensions);

  Matrix4 pathTransform(ILayoutData dimensions);

  /// Convert a length to screen pixels (for stroke width, radius, etc.).
  double toScreenLength(double value, ILayoutData dimensions);
}

/// Interface for chart renderers
abstract class IChartRenderer {
  void render(
    ChartRenderContext context,
    ISparklinesData data,
  );
}

abstract class IDataPointRenderer {
  void render(
    Paint paint,
    ChartRenderContext context,
    IDataPointStyle style,
    DataPoint dataPoint,
  );
}

/// Base interface for all chart data types
abstract class ISparklinesData implements ILerpTo<ISparklinesData> {
  /// Whether this chart is visible
  bool get visible;

  /// Rotation (d90/d270 use swapped dimensions so chart fills bounds)
  ChartRotation get rotation;

  /// Origin offset for positioning
  Offset get origin;

  /// Optional layout override for this specific data series
  IChartLayout? get layout;

  /// Whether to crop rendering to bounds (null uses chart default)
  bool? get crop;

  /// Renderer for this chart type
  IChartRenderer get renderer;

  /// Minimum X coordinate from data points
  double get minX;

  /// Maximum X coordinate from data points
  double get maxX;

  /// Minimum Y coordinate from data points
  double get minY;

  /// Maximum Y coordinate from data points
  double get maxY;

  /// Check if this chart should repaint compared to [other]
  /// Returns true if any property that affects rendering has changed
  bool shouldRepaint(ISparklinesData other);
}

/// Style interface for data points
abstract class IDataPointStyle implements ILerpTo<IDataPointStyle> {

  IDataPointRenderer get renderer;

}

/// Marker interface for line type data
abstract class ILineTypeData {}

/// Step line type data
class SteppedLineType implements ILineTypeData {

  /// 0.0 → previous point, 1.0 → next point
  final double stepJumpAt;

  const SteppedLineType({this.stepJumpAt = 0.5});
  const SteppedLineType.start() : stepJumpAt = 0.0;
  const SteppedLineType.middle() : stepJumpAt = 0.5;
  const SteppedLineType.end() : stepJumpAt = 1.0;
}

class CurvedLineType implements ILineTypeData {

  /// Curve smoothness (0.0 to 1.0)
  final double smoothness;

  const CurvedLineType({this.smoothness = 0.35});
}
