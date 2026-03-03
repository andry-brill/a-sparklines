import 'dart:math';

import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart';

import 'layout.dart';

class ChartTransform {

  final Matrix4 _transform;
  final IChartLayout _layout;
  final ILayoutData _dimensions;

  ChartTransform({
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

  /// If we cannot (re)draw the path after applying the transformation, we need to apply an anti-scaling factor to values such as stroke width, radius, and similar properties.
  double antiScalar(double value) => value * _antiScalarK;

  double? _uniformK;

  double get _antiScalarK {

    if (_uniformK != null) return _uniformK!;

    Matrix4 m = _transform;

    // 2D linear part A = [[a, c], [b, d]]
    final a = m.entry(0, 0);
    final b = m.entry(1, 0);
    final c = m.entry(0, 1);
    final d = m.entry(1, 1);

    final p = a * a + b * b;
    final q = c * c + d * d;
    final r = a * c + b * d;

    final trace = p + q;
    final discr = (p - q) * (p - q) + 4.0 * r * r;

    final lambdaMax = 0.5 * (trace + sqrt(discr));
    final sMax = sqrt(lambdaMax);

    if (sMax == 0) return 1.0;
    return _uniformK = (1.0 / sMax);
  }
}
