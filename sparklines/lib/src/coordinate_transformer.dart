import 'package:flutter/material.dart';
import 'package:sparklines/src/data/data_point.dart';
import 'interfaces.dart';

/// Transforms data coordinates to screen coordinates
class CoordinateTransformer implements ILayoutDimensions {

  @override
  final double minX;
  @override
  final double maxX;
  @override
  final double minY;
  @override
  final double maxY;
  @override
  final double width;
  @override
  final double height;

  /// Bounds rect (0, 0, width, height) for shaders and clipping
  final Rect bounds;

  late final IChartLayout layout;
  final bool crop;

  CoordinateTransformer({
    required this.minX,
    required this.maxX,
    required this.minY,
    required this.maxY,
    required this.width,
    required this.height,
    required IChartLayout layout,
    required this.crop,
  }) : bounds = Rect.fromLTWH(0, 0, width, height) {
    assert(minX < maxX, 'minX must be less than maxX');
    assert(minY < maxY, 'minY must be less than maxY');
    // Resolve layout with this transformer's dimensions
    this.layout = layout.resolve(this);
  }

  double transformX(double x) {
    return layout.transformX(x, this);
  }

  double transformDx(double x) {
    return layout.transformDx(x, this);
  }

  double transformY(double y) {
    return layout.transformY(y, this);
  }

  double transformDy(double y) {
    return layout.transformDy(y, this);
  }

  Offset transformPoint(DataPoint p) {
    return Offset(transformX(p.x), transformY(p.fy));
  }

  double transformDimension(double value) {
    return layout.transformDimension(value, this);
  }

}
