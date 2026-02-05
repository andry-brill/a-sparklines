import 'package:flutter/material.dart';

/// Transforms data coordinates to screen coordinates
class CoordinateTransformer {
  final double minX;
  final double maxX;
  final double minY;
  final double maxY;
  final double width;
  final double height;
  final bool relativeDataPoints;
  final bool relativeDimensions;
  final bool crop;

  CoordinateTransformer({
    required this.minX,
    required this.maxX,
    required this.minY,
    required this.maxY,
    required this.width,
    required this.height,
    this.relativeDataPoints = true,
    this.relativeDimensions = true,
    this.crop = false,
  }) {
    assert(minX < maxX, 'minX must be less than maxX');
    assert(minY < maxY, 'minY must be less than maxY');
  }

  /// Transform X coordinate from data space to screen space
  double transformX(double x) {
    if (relativeDataPoints) {
      return (x - minX) / (maxX - minX) * width;
    } else {
      return (x - minX) * (width / (maxX - minX));
    }
  }

  /// Transform Y coordinate from data space to screen space
  /// Y is inverted to keep math natural for chart data
  double transformY(double y) {
    if (relativeDataPoints) {
      return height - ((y - minY) / (maxY - minY) * height);
    } else {
      return height - ((y - minY) * (height / (maxY - minY)));
    }
  }

  /// Transform a point from data space to screen space
  Offset transformPoint(double x, double y) {
    return Offset(transformX(x), transformY(y));
  }

  /// Transform a relative width to absolute pixels
  double transformWidth(double relativeWidth) {
    if (relativeDimensions) {
      return relativeWidth * width;
    } else {
      return relativeWidth;
    }
  }

  /// Check if a point is within the plot bounds
  bool isWithinBounds(double x, double y) {
    return x >= minX && x <= maxX && y >= minY && y <= maxY;
  }
}
