import 'package:flutter/material.dart';
import 'dart:ui' show lerpDouble;
import 'coordinate_transformer.dart';

/// Interface for types that can be interpolated
abstract class ILerpable<T> {
  /// Interpolate between this and [next] using interpolation factor [t] (0.0 to 1.0)
  T lerpTo(T next, double t);
}

/// Interface for layout dimensions
abstract class ILayoutDimensions {
  double get minX;
  double get maxX;
  double get minY;
  double get maxY;
  double get width;
  double get height;
}

/// Chart layout interface for defining coordinate transformation
abstract class IChartLayout {
  /// Whether to crop rendering to bounds
  bool get crop;

  /// Resolve layout with actual dimensions (e.g., resolve infinity values)
  /// Returns a resolved layout that can be used for transformation
  IChartLayout resolve(ILayoutDimensions dimensions);

  /// Transform X coordinate from data space to screen space
  double transformX(double x, ILayoutDimensions dimensions);

  /// Transform Y coordinate from data space to screen space
  double transformY(double y, ILayoutDimensions dimensions);

  /// Transform a dimensional value based on layout settings
  double transformDimension(double value, ILayoutDimensions dimensions);
}

/// Interface for chart renderers
abstract class IChartRenderer {
  /// Render the chart to the canvas
  void render(
    Canvas canvas,
    CoordinateTransformer transformer,
    ISparklinesData data,
  );
}

/// Base interface for all chart data types
abstract class ISparklinesData implements ILerpable<ISparklinesData> {
  /// Whether this chart is visible
  bool get visible;

  /// Rotation in radians
  double get rotation;

  /// Origin offset for positioning
  Offset get origin;

  /// Optional layout override for this specific data series
  IChartLayout? get layout;

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
abstract class IDataPointStyle implements ILerpable<IDataPointStyle> {}

/// Circle style for data points
class CircleDataPointStyle implements IDataPointStyle {
  final double radius;
  final Color color;

  const CircleDataPointStyle({
    required this.radius,
    required this.color,
  });

  @override
  IDataPointStyle lerpTo(IDataPointStyle next, double t) {
    if (next is! CircleDataPointStyle) return next;

    return CircleDataPointStyle(
      radius: lerpDouble(radius, next.radius, t) ?? next.radius,
      color: Color.lerp(color, next.color, t) ?? next.color,
    );
  }
}

/// Marker interface for line type data
abstract class ILineTypeData {}

/// Step line type data
class LineChartStepData implements ILineTypeData {
  /// 0.0 → previous point, 1.0 → next point
  final double stepJumpAt;

  const LineChartStepData({this.stepJumpAt = 0.5});
}

/// Curve line type data
class LineChartCurveData implements ILineTypeData {
  /// Curve smoothness (0.0 to 1.0)
  final double curveSmoothness;

  const LineChartCurveData({this.curveSmoothness = 0.35});
}
