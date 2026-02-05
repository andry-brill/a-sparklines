import 'package:flutter/material.dart';

/// Base interface for all chart data types
abstract class ISparklinesData {
  /// Whether this chart is visible
  bool get visible;

  /// Rotation in radians
  double get rotation;

  /// Origin offset for positioning
  Offset get origin;
}

/// Style interface for data points
abstract class IDataPointStyle {}

/// Circle style for data points
class CircleDataPointStyle implements IDataPointStyle {
  final double radius;
  final Color color;

  const CircleDataPointStyle({
    required this.radius,
    required this.color,
  });
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
