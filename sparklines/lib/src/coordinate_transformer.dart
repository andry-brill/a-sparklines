import 'package:flutter/material.dart';
import 'package:sparklines/src/data/data_point.dart';
import 'data/layout_data.dart';
import 'interfaces.dart';

/// Transforms data coordinates to screen coordinates
class CoordinateTransformer {

  final LayoutData data;
  /// Bounds rect (0, 0, width, height) for shaders and clipping
  final Rect bounds;
  Offset get center => bounds.center;

  final IChartLayout layout;
  final bool crop;

  CoordinateTransformer({
    required this.data,
    required this.layout,
    required this.crop,
  }) :
        bounds = Rect.fromLTWH(0, 0, data.width, data.height);

  double transformX(double x) {
    return layout.transformX(x, data);
  }

  double transformDx(double x) {
    return layout.transformDx(x, data);
  }

  double transformY(double y) {
    return layout.transformY(y, data);
  }

  double transformDy(double y) {
    return layout.transformDy(y, data);
  }

  Offset transformPoint(DataPoint p) {
    return Offset(transformX(p.x), transformY(p.fy));
  }

  double transformDimension(double value) {
    return layout.transformDimension(value, data);
  }

}
