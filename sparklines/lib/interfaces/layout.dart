import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart';

/// Interface for layout dimensions
abstract class ILayoutData {
  double get minX;
  double get maxX;
  double get minY;
  double get maxY;
  double get width;
  double get height;
}

/// Chart layout interface: applies canvas transformation so drawing uses data coordinates.
abstract class IChartLayout {
  /// Resolve layout with actual dimensions (e.g., resolve infinity values).
  IChartLayout resolve(List<ILayoutData> dimensions);

  Matrix4 transform(ILayoutData dimensions);

  /// Apply transformation to scalar values like stroke width, radius, etc.
  double transformScalar(double value, ILayoutData dimensions);
}
