import 'package:flutter/material.dart';

import 'chart_transform.dart';
import 'lerp.dart';

/// Style interface for data points
abstract class IDataPointStyle implements ILerpTo<IDataPointStyle> {
  IDataPointRenderer get renderer;
}

/// Renders a single data point.
/// The [dataPoint] argument is a [DataPoint] from package data (passed as Object to avoid circular imports).
abstract class IDataPointRenderer {
  void render(
    Canvas canvas,
    ChartTransform transform,
    Paint paint,
    IDataPointStyle style,
    Object dataPoint,
  );
}
