import 'dart:math';

import 'package:flutter/material.dart';
import 'package:sparklines/sparklines.dart';
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


class ThicknessOverride implements ILerpTo<ThicknessOverride> {

  final double? size;
  final Gradient? gradient;
  final double? align;
  final Color? color;

  const ThicknessOverride({
    this.align,
    this.size,
    this.color,
    this.gradient,
  });

  @override
  ThicknessOverride lerpTo(ThicknessOverride next, double t) {
    return ThicknessOverride(
      size: lerpDouble(size, next.size, t),
      align: lerpDouble(align, next.align, t),
      color: Color.lerp(color, next.color, t),
      gradient: Gradient.lerp(gradient, next.gradient, t),
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
    final point = pathTransform.transform3(Vector3(dataPoint.x, dataPoint.fy, 0.0));
    return Offset(point.x, point.y);
  }

  Offset transformXY(double x, double y) {
    final point = pathTransform.transform3(Vector3(x, y, 0.0));
    return Offset(point.x, point.y);
  }

  void drawCircle(DataPoint dataPoint, double radius, Paint paint) {
    canvas.drawCircle(transform(dataPoint), radius, paint);
  }

  void drawPath(Path path, Paint paint) {
    final tPath = path.transform(pathTransform.storage);
    canvas.drawPath(tPath, paint);
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

/// Interface for line type renderers (path building + stroke rendering)
abstract class ILineTypeRenderer {
  Path toPath(ILineTypeData lineType, List<DataPoint> points, {bool useFy = true, bool reverse = false, Path? path});
  void render(ChartRenderContext context, LineData lineData);
}

/// Marker interface for line type data
abstract class ILineTypeData {
  bool get isStrokeCapRound;
  bool get isStrokeJoinRound;
  ILineTypeRenderer get renderer;
}

