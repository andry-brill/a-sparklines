import 'package:any_sparklines/data/data_point.dart';
import 'package:flutter/material.dart';

import 'chart_transform.dart';
import 'data_point_data.dart';

/// Style interface for data points
abstract class IDataPointStyle implements IDataPointData {
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
