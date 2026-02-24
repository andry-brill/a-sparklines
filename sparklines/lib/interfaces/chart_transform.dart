import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart';

import 'layout.dart';

class ChartTransform {
  final Matrix4 _transform;
  final IChartLayout _layout;
  final ILayoutData _dimensions;

  const ChartTransform({
    required IChartLayout layout,
    required ILayoutData dimensions,
    required Matrix4 pathTransform,
  })  : _dimensions = dimensions,
        _layout = layout,
        _transform = pathTransform;

  /// Apply transformation to scalar values like stroke width, radius, etc.
  double scalar(double value) => _layout.transformScalar(value, _dimensions);

  Vector3 v3(Vector3 v3) => _transform.transform3(v3);
  Path path(Path path) => path.transform(_transform.storage);

  Offset xy(double x, double y) {
    final point = v3(Vector3(x, y, 0.0));
    return Offset(point.x, point.y);
  }
}
