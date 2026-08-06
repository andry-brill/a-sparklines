import 'dart:math';

import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart';

import 'layout.dart';
import 'length_value.dart';

class ChartTransform implements ILengthContext {
  final Matrix4 _transform;
  final ILayoutData _dimensions;

  ChartTransform({
    required ILayoutData dimensions,
    required Matrix4 pathTransform,
  })  : _dimensions = dimensions,
        _transform = pathTransform;

  /// Resolves a visual length in the current viewport and data transform.
  double length(ILengthValue value) => value.resolve(this);

  @override
  double get viewportWidth => _dimensions.width;

  @override
  double get viewportHeight => _dimensions.height;

  @override
  double dataX(double value) => _dataDistance(value, 0.0);

  @override
  double dataY(double value) => _dataDistance(0.0, value);

  double _dataDistance(double x, double y) {
    final origin = v3(Vector3.zero());
    final endpoint = v3(Vector3(x, y, 0.0));
    return (endpoint - origin).length;
  }

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
