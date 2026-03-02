import 'package:flutter/material.dart';

import 'chart_flip.dart';
import 'chart_rotation.dart';
import 'chart_transform.dart';
import 'layout.dart';
import 'lerp.dart';

/// Interface for chart renderers
abstract class IChartRenderer {
  void render(
    Canvas canvas,
    ChartTransform transform,
    ISparklinesData data,
  );
}

/// Base interface for all chart data types
abstract class ISparklinesData implements ILerpTo<ISparklinesData> {
  /// Whether this chart is visible
  bool get visible;

  /// Rotation (d90/d270 use swapped dimensions so chart fills bounds)
  ChartRotation get rotation;

  /// Flip: none, vertically, horizontally, or both
  ChartFlip get flip;

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
