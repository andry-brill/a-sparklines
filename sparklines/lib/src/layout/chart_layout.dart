import 'dart:math';

import 'package:flutter/material.dart';

import '../interfaces.dart';
import 'relative_dimension.dart';

/// Math-oriented coordinates: origin at bottom-left, Y up.
/// Prepares canvas by offsetting by height and scaling (1, -1).
class AbsoluteLayout implements IChartLayout {
  const AbsoluteLayout();

  @override
  IChartLayout resolve(List<ILayoutData> dimensions) => this;

  @override
  void prepare(Canvas canvas, ILayoutData dimensions) {
    canvas.translate(0, dimensions.height);
    canvas.scale(1, -1);
  }

  @override
  Offset centerInDataSpace(ILayoutData dimensions) {
    return Offset(dimensions.width / 2, dimensions.height / 2);
  }

  @override
  double toScreenLength(double value, ILayoutData dimensions, [RelativeDimension relativeTo = RelativeDimension.none]) {
    return value;
  }
}

/// Relative transformation to explicit bounds
/// Can use infinity values for auto-calculation from data
class RelativeLayout implements IChartLayout {

  final double minX;
  final double maxX;
  final double minY;
  final double maxY;
  final RelativeDimension relativeTo;

  const RelativeLayout({
    required this.minX,
    required this.maxX,
    required this.minY,
    required this.maxY,
    this.relativeTo = RelativeDimension.none,
  });

  const RelativeLayout.normalized({
    this.minX = 0.0,
    this.maxX = 1.0,
    this.minY = 0.0,
    this.maxY = 1.0,
    this.relativeTo = RelativeDimension.none,
  });

  const RelativeLayout.signed({
    this.minX = -1.0,
    this.maxX = 1.0,
    this.minY = -1.0,
    this.maxY = 1.0,
    this.relativeTo = RelativeDimension.none,
  });

  /// Full cover from min to max data
  const RelativeLayout.full({
    this.minX = double.negativeInfinity,
    this.maxX = double.infinity,
    this.minY = double.negativeInfinity,
    this.maxY = double.infinity,
    this.relativeTo = RelativeDimension.none,
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

    final finalMinX = resolvedMinX == resolvedMaxX ? resolvedMinX - 1.0 : resolvedMinX;
    final finalMaxX = resolvedMinX == resolvedMaxX ? resolvedMaxX + 1.0 : resolvedMaxX;
    final finalMinY = resolvedMinY == resolvedMaxY ? resolvedMinY - 1.0 : resolvedMinY;
    final finalMaxY = resolvedMinY == resolvedMaxY ? resolvedMaxY + 1.0 : resolvedMaxY;

    return RelativeLayout(
      minX: finalMinX,
      maxX: finalMaxX,
      minY: finalMinY,
      maxY: finalMaxY,
    );
  }

  @override
  void prepare(Canvas canvas, ILayoutData dimensions) {
    canvas.translate(0, dimensions.height);
    canvas.scale(1, -1);
    canvas.scale(dimensions.width / (maxX - minX), dimensions.height / (maxY - minY));
    canvas.translate(-minX, -minY);
  }

  @override
  Offset centerInDataSpace(ILayoutData dimensions) {
    return Offset((minX + maxX) / 2, (minY + maxY) / 2);
  }

  @override
  double toScreenLength(double value, ILayoutData dimensions, [RelativeDimension relativeTo = RelativeDimension.none]) {
    switch (relativeTo) {
      case RelativeDimension.none:
        return value;
      case RelativeDimension.width:
        if (value == double.negativeInfinity) return 0;
        if (value == double.infinity) return dimensions.width;
        return value * (dimensions.width / (maxX - minX));
      case RelativeDimension.height:
        if (value == double.negativeInfinity) return 0;
        if (value == double.infinity) return dimensions.height;
        return value * (dimensions.height / (maxY - minY));
    }
  }
}
