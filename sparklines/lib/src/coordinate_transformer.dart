import 'package:flutter/material.dart';
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
  }) {
    assert(minX < maxX, 'minX must be less than maxX');
    assert(minY < maxY, 'minY must be less than maxY');
    // Resolve layout with this transformer's dimensions
    this.layout = layout.resolve(this);
  }

  /// Transform X coordinate from data space to screen space
  double transformX(double x) {
    return layout.transformX(x, this);
  }

  /// Transform Y coordinate from data space to screen space
  /// Y is inverted to keep math natural for chart data
  double transformY(double y) {
    return layout.transformY(y, this);
  }

  /// Transform a point from data space to screen space
  Offset transformPoint(double x, double y) {
    return Offset(transformX(x), transformY(y));
  }

  /// Transform a relative width to absolute pixels
  double transformWidth(double relativeWidth) {
    return transformDimension(relativeWidth);
  }

  /// Transform a dimensional value based on layout settings
  double transformDimension(double value) {
    return layout.transformDimension(value, this);
  }

}
