import 'dart:math';
import 'package:flutter/material.dart';
import 'package:sparklines/sparklines.dart';
import 'package:sparklines/src/layout/circle_arc_builder.dart';
import 'data_point.dart';

/// Result of computing layout for a single pie slice (angle order, radii, space).
class PieSliceData {

  final double startAngle;
  final double endAngle;
  final double innerRadius;
  final double outerRadius;
  final Offset offset;
  final double cornerRadius;

  final DataPoint point;

  const PieSliceData({
    required this.startAngle,
    required this.endAngle,
    required this.innerRadius,
    required this.outerRadius,
    required this.offset,
    required this.point,
    required this.cornerRadius,
  });

  /// Builds filled arc path using [CircleArcBuilder] with uniform thickness in screen space.
  Path toPath() {

    final arcBuilder = CircleArcBuilder(
      innerRadius: innerRadius,
      outerRadius: outerRadius,
      startAngle: startAngle + pi/2,
      endAngle: endAngle + pi/2,
      padAngle: 0.0,
      cornerRadius: cornerRadius,
    );

    Path path = arcBuilder.build();

    if (offset.dx != 0.0 || offset.dy != 0.0) {
      path = path.shift(offset);
    }

    return path;
  }
}

/// Computes slice layout for pie chart.
/// - Each point (x, y) defines an arc: r = x, startAngle = y, endAngle = y + dy.
/// - innerRadius = x - thicknessAlignedLeft, outerRadius = x + thicknessAlignedRight based on thicknessAlign.
/// - space = uniform linear gap between slices, set as spaceOffset (aligned with arc midpoint angle).
List<PieSliceData> computePies(
  List<DataPoint> points,
  double space,
  ThicknessData thickness,
  double radius,
  ChartRenderContext? context
) {

  final cornerRadius = context != null ? context.toScreenLength(radius) : radius;

  List<PieSliceData> layouts = [];

  for (var point in points) {

    final thicknessAlign = point.thickness?.align ?? thickness.align;
    double thicknessSize = point.thickness?.size ?? thickness.size;

    if (context != null) {
      thicknessSize = context.toScreenLength(thicknessSize);
    }

    if (point.x <= 0 || thickness.size <= 0) continue;

    final halfThicknessLeft = thicknessSize * (1 + thicknessAlign) / 2;
    final halfSweepRight = thicknessSize * (1 - thicknessAlign) / 2;

    final innerRadius = max(0.0, point.x - halfThicknessLeft);
    final outerRadius = point.x + halfSweepRight;

    final startAngle = point.y;
    final endAngle = point.fy;
    final midAngle = startAngle + (endAngle - startAngle) / 2;

    final spaceHalf = space / 2;
    final spaceOffset = Offset(
      spaceHalf * cos(midAngle),
      spaceHalf * sin(midAngle),
    );

    layouts.add(PieSliceData(
      startAngle: startAngle,
      endAngle: endAngle,
      innerRadius: innerRadius,
      outerRadius: outerRadius,
      offset: spaceOffset,
      point: point,
      cornerRadius: min(cornerRadius, (outerRadius - innerRadius)/2)
    ));

  }

  return layouts;

}
