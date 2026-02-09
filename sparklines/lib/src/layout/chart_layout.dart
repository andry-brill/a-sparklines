import 'dart:math';

import '../interfaces.dart';
import 'relative_dimension.dart';


/// No transformations at all, returning values as is
class AbsoluteLayout implements IChartLayout {

  const AbsoluteLayout();

  @override
  IChartLayout resolve(List<ILayoutData> dimensions) => this;

  @override
  double transformDimension(double value, ILayoutData dimensions) => value;

  @override
  double transformX(double x, ILayoutData dimensions) => x;

  @override
  // Y is inverted to keep math natural for chart data
  double transformY(double y, ILayoutData dimensions) => dimensions.height - y;

  @override
  double transformDx(double x, ILayoutData dimensions) => x;

  @override
  double transformDy(double y, ILayoutData dimensions) => y;

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
  double transformX(double x, ILayoutData dimensions) => transformDx(x - minX, dimensions);

  @override
  double transformDx(double dx, ILayoutData dimensions) => dx * (dimensions.width / (maxX - minX));

  @override
  double transformY(double y, ILayoutData dimensions) {
    // Y is inverted to keep math natural for chart data
    return dimensions.height - transformDy(y - minY, dimensions);
  }

  @override
  double transformDy(double dy, ILayoutData dimensions) => dy * (dimensions.height / (maxY - minY));

  @override
  double transformDimension(double value, ILayoutData dimensions) {
    switch (relativeTo) {
      case RelativeDimension.none:
        return value;
      case RelativeDimension.width:

        if (value == double.negativeInfinity) {
          value = dimensions.minX;
        } else if (value == double.infinity) {
          value = dimensions.maxX;
        }

        return transformDx(value, dimensions);
      case RelativeDimension.height:

        if (value == double.negativeInfinity) {
          value = dimensions.minY;
        } else if (value == double.infinity) {
          value = dimensions.maxY;
        }

        return transformDy(value, dimensions);
    }
  }
}
