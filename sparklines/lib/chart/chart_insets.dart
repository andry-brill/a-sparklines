import 'dart:math' as math;

import 'package:vector_math/vector_math_64.dart';

import '../data/data_point.dart';
import '../interfaces/chart_insets.dart';
import '../interfaces/chart_transform.dart';
import '../interfaces/layout.dart';
import '../interfaces/length_value.dart';

class ResolvedChartInsets {
  final double left;
  final double top;
  final double right;
  final double bottom;

  const ResolvedChartInsets({
    this.left = 0.0,
    this.top = 0.0,
    this.right = 0.0,
    this.bottom = 0.0,
  });

  bool get isEmpty => left == 0.0 && top == 0.0 && right == 0.0 && bottom == 0.0;

  ResolvedChartInsets add(ResolvedChartInsets other) => ResolvedChartInsets(
    left: left + other.left,
    top: top + other.top,
    right: right + other.right,
    bottom: bottom + other.bottom,
  );

  ResolvedChartInsets maxWith(ResolvedChartInsets other) => ResolvedChartInsets(
    left: math.max(left, other.left),
    top: math.max(top, other.top),
    right: math.max(right, other.right),
    bottom: math.max(bottom, other.bottom),
  );
}

double _resolveInset(ChartTransform transform, ILengthValue? value) {
  if (value == null) return 0.0;
  final resolved = transform.length(value);
  if (!resolved.isFinite) return 0.0;
  return math.max(0.0, resolved);
}

ResolvedChartInsets resolveChartInsets(ChartTransform transform, IDataPointExtent insets) => ResolvedChartInsets(
  left: _resolveInset(transform, insets.left),
  top: _resolveInset(transform, insets.top),
  right: _resolveInset(transform, insets.right),
  bottom: _resolveInset(transform, insets.bottom),
);

ResolvedChartInsets resolveDataPointOverflow(ChartTransform transform, ILayoutData dimensions, Iterable<DataPoint> points) {
  var result = const ResolvedChartInsets();

  for (final point in points) {
    final extent = point.extent;
    if (extent == null) continue;
    final resolved = resolveChartInsets(transform, extent);
    final anchor = transform.xy(point.x, point.fy);
    result = result.maxWith(ResolvedChartInsets(
      left: math.max(0.0, resolved.left - anchor.dx),
      top: math.max(0.0, resolved.top - anchor.dy),
      right: math.max(0.0, resolved.right - (dimensions.width - anchor.dx)),
      bottom: math.max(0.0, resolved.bottom - (dimensions.height - anchor.dy)),
    ));
  }

  return result;
}

Matrix4 insetChartMatrix(Matrix4 preliminary, ILayoutData dimensions, ResolvedChartInsets insets) {
  if (insets.isEmpty || dimensions.width <= 0.0 || dimensions.height <= 0.0) return preliminary;

  final horizontal = insets.left + insets.right;
  final vertical = insets.top + insets.bottom;
  final collapseX = horizontal >= dimensions.width;
  final collapseY = vertical >= dimensions.height;
  final offsetX = collapseX ? dimensions.width * insets.left / horizontal : insets.left;
  final offsetY = collapseY ? dimensions.height * insets.top / vertical : insets.top;
  final scaleX = collapseX ? 0.0 : (dimensions.width - horizontal) / dimensions.width;
  final scaleY = collapseY ? 0.0 : (dimensions.height - vertical) / dimensions.height;

  return Matrix4.identity()
    ..translateByVector3(Vector3(offsetX, offsetY, 0.0))
    ..scaleByVector3(Vector3(scaleX, scaleY, 1.0))
    ..multiply(preliminary);
}
