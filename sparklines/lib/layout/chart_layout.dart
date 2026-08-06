import 'dart:math';

import 'package:vector_math/vector_math_64.dart';

import '../interfaces/layout.dart';

/// Math-oriented coordinates: origin at bottom-left, Y up.
/// Prepares canvas by offsetting by height and scaling (1, -1).
class AbsoluteLayout implements IChartLayout {
  const AbsoluteLayout();

  @override
  IChartLayout resolve(List<ILayoutData> dimensions) => this;

  @override
  Matrix4 transform(ILayoutData dimensions) {
    return Matrix4.identity()
      ..translateByVector3(Vector3(0.0, dimensions.height, 0.0))
      ..scaleByVector3(Vector3(1.0, -1.0, 0.0));
  }
}

/// Relative transformation to explicit bounds
/// Can use infinity values for auto-calculation from data
class RelativeLayout implements IChartLayout {
  final double minX;
  final double maxX;
  final double minY;
  final double maxY;
  const RelativeLayout({
    this.minX = 0,
    required this.maxX,
    this.minY = 0,
    required this.maxY,
  });

  const RelativeLayout.normalized({
    this.minX = 0.0,
    this.maxX = 1.0,
    this.minY = 0.0,
    this.maxY = 1.0,
  });

  const RelativeLayout.signed({
    this.minX = -1.0,
    this.maxX = 1.0,
    this.minY = -1.0,
    this.maxY = 1.0,
  });

  /// Full cover from min to max data
  const RelativeLayout.full({
    this.minX = double.negativeInfinity,
    this.maxX = double.infinity,
    this.minY = double.negativeInfinity,
    this.maxY = double.infinity,
  });

  @override
  IChartLayout resolve(List<ILayoutData> dimensions) {
    assert(dimensions.isNotEmpty);

    final effectiveMinX = dimensions.map((d) => d.minX).reduce(min);
    final effectiveMaxX = dimensions.map((d) => d.maxX).reduce(max);
    final effectiveMinY = dimensions.map((d) => d.minY).reduce(min);
    final effectiveMaxY = dimensions.map((d) => d.maxY).reduce(max);

    final resolvedMinX = minX.isFinite ? minX : effectiveMinX;
    final resolvedMaxX = maxX.isFinite ? maxX : effectiveMaxX;
    final resolvedMinY = minY.isFinite ? minY : effectiveMinY;
    final resolvedMaxY = maxY.isFinite ? maxY : effectiveMaxY;

    final finalMinX =
        resolvedMinX == resolvedMaxX ? resolvedMinX - 1.0 : resolvedMinX;
    final finalMaxX =
        resolvedMinX == resolvedMaxX ? resolvedMaxX + 1.0 : resolvedMaxX;
    final finalMinY =
        resolvedMinY == resolvedMaxY ? resolvedMinY - 1.0 : resolvedMinY;
    final finalMaxY =
        resolvedMinY == resolvedMaxY ? resolvedMaxY + 1.0 : resolvedMaxY;

    return RelativeLayout(
      minX: finalMinX,
      maxX: finalMaxX,
      minY: finalMinY,
      maxY: finalMaxY,
    );
  }

  @override
  Matrix4 transform(ILayoutData dimensions) {
    return Matrix4.identity()
      ..translateByVector3(Vector3(0.0, dimensions.height, 0.0))
      ..scaleByVector3(Vector3(1.0, -1.0, 1.0))
      ..scaleByVector3(Vector3(dimensions.width / (maxX - minX),
          dimensions.height / (maxY - minY), 1.0))
      ..translateByVector3(Vector3(-minX, -minY, 0.0));
  }
}
