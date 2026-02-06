import 'interfaces.dart';
import 'relative_dimension.dart';

/// Absolute layout with explicit bounds (non-relative transformation)
/// Can use infinity values for auto-calculation from data
class AbsoluteLayout implements IChartLayout {
  final double minX;
  final double maxX;
  final double minY;
  final double maxY;

  const AbsoluteLayout({
    this.minX = double.negativeInfinity,
    this.maxX = double.infinity,
    this.minY = double.negativeInfinity,
    this.maxY = double.infinity,
  });

  @override
  IChartLayout resolve(ILayoutDimensions dimensions) {
    // Use AbsoluteLayout's bounds if finite, otherwise use dimensions
    final resolvedMinX = minX.isFinite ? minX : dimensions.minX;
    final resolvedMaxX = maxX.isFinite ? maxX : dimensions.maxX;
    final resolvedMinY = minY.isFinite ? minY : dimensions.minY;
    final resolvedMaxY = maxY.isFinite ? maxY : dimensions.maxY;

    // Handle case where min == max
    final finalMinX = resolvedMinX == resolvedMaxX ? resolvedMinX - 1.0 : resolvedMinX;
    final finalMaxX = resolvedMinX == resolvedMaxX ? resolvedMaxX + 1.0 : resolvedMaxX;
    final finalMinY = resolvedMinY == resolvedMaxY ? resolvedMinY - 1.0 : resolvedMinY;
    final finalMaxY = resolvedMinY == resolvedMaxY ? resolvedMaxY + 1.0 : resolvedMaxY;

    return AbsoluteLayout(
      minX: finalMinX,
      maxX: finalMaxX,
      minY: finalMinY,
      maxY: finalMaxY,
    );
  }

  @override
  double transformX(double x, ILayoutDimensions dimensions) {
    return (x - dimensions.minX) * (dimensions.width / (dimensions.maxX - dimensions.minX));
  }

  @override
  double transformY(double y, ILayoutDimensions dimensions) {
    // Y is inverted to keep math natural for chart data
    return dimensions.height - ((y - dimensions.minY) * (dimensions.height / (dimensions.maxY - dimensions.minY)));
  }

  @override
  double transformDimension(double value, ILayoutDimensions dimensions) {
    return value;
  }
}

/// Relative layout with normalized bounds (0.0-1.0)
class RelativeLayout implements IChartLayout {
  final RelativeDimension relativeTo;

  const RelativeLayout({
    this.relativeTo = RelativeDimension.width,
  });

  @override
  IChartLayout resolve(ILayoutDimensions dimensions) {
    // RelativeLayout doesn't need resolution, return itself
    return this;
  }

  @override
  double transformX(double x, ILayoutDimensions dimensions) {
    // Relative layout treats data points as 0.0-1.0
    return (x - dimensions.minX) / (dimensions.maxX - dimensions.minX) * dimensions.width;
  }

  @override
  double transformY(double y, ILayoutDimensions dimensions) {
    // Y is inverted to keep math natural for chart data
    // Relative layout treats data points as 0.0-1.0
    return dimensions.height - ((y - dimensions.minY) / (dimensions.maxY - dimensions.minY) * dimensions.height);
  }

  @override
  double transformDimension(double value, ILayoutDimensions dimensions) {
    if (value == double.infinity || value == double.negativeInfinity) {
      return value;
    }

    switch (relativeTo) {
      case RelativeDimension.none:
        return value;
      case RelativeDimension.width:
        return transformX(value, dimensions);
      case RelativeDimension.height:
        return transformY(value, dimensions);
    }
  }
}
