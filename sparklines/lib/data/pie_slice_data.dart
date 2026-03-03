import 'dart:math';
import 'package:flutter/material.dart';
import '../interfaces/chart_transform.dart';
import '../interfaces/thickness.dart';
import '../layout/circle_arc_builder.dart';
import 'data_point.dart';


/// Result of computing layout for a single pie slice (angle order, radii, space).
class PieSliceData {

  final double startAngle;
  final double endAngle;
  final double innerRadius;
  final double outerRadius;
  final double padAngle;
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
    required this.padAngle,
  });

  /// Builds filled arc path using [CircleArcBuilder] with uniform thickness in screen space.
  Path toPath() {

    final arcBuilder = CircleArcBuilder(
      innerRadius: innerRadius,
      outerRadius: outerRadius,
      startAngle: startAngle + pi/2,
      endAngle: endAngle + pi/2,
      padAngle: padAngle,
      cornerRadius: cornerRadius,
    );

    Path path = arcBuilder.build();

    if (offset.dx != 0.0 || offset.dy != 0.0) {
      path = path.shift(offset);
    }

    return path;
  }
}

Offset toCartesian(double radius, DataPoint point) {
  final midAngle = point.y + point.dy / 2;
  final dx = radius * cos(midAngle);
  final dy = radius * sin(midAngle);
  return Offset(dx, dy);
}

/// Computes slice layout for pie chart.
/// - Each point (x, y) defines an arc: r = x, startAngle = y, endAngle = y + dy.
/// - innerRadius = x - thicknessAlignedLeft, outerRadius = x + thicknessAlignedRight based on thicknessAlign.
/// - space = uniform linear gap between slices, set as spaceOffset (aligned with arc midpoint angle).
List<PieSliceData> computePies(
  List<DataPoint> pies,
  double offset,
  double padAngle,
  ThicknessData thickness,
  double? radius,
  ChartTransform? transform
) {

  List<PieSliceData> layouts = [];

  for (var pie in pies) {

    final borderRadius = pie.border?.borderRadius ?? radius ?? 0.0;
    final cornerRadius = transform != null ? transform.scalar(transform.antiScalar(borderRadius)) : borderRadius;

    final thicknessAlign = pie.thickness?.align ?? thickness.align;
    double thicknessSize = pie.thickness?.size ?? thickness.size;

    if (transform != null) {
      thicknessSize = transform.scalar(transform.antiScalar(thicknessSize));
    }

    if (pie.x <= 0.0001 || thicknessSize <= 0.0001 || pie.dy <= 0.0001) continue;

    final halfInnerThickness = thicknessSize * (1 - thicknessAlign) / 2;
    final halfOuterThickness = thicknessSize * (1 + thicknessAlign) / 2;

    final innerRadius = max(0.0, pie.x - halfInnerThickness);
    final outerRadius = pie.x + halfOuterThickness;

    final pointDx = pie.pieOffset?.pieOffset  ?? offset;
    final spaceOffset = toCartesian(pointDx, pie);

    layouts.add(PieSliceData(
      startAngle: pie.y,
      endAngle: pie.fy,
      innerRadius: innerRadius,
      outerRadius: outerRadius,
      offset: spaceOffset,
      point: pie,
      cornerRadius: min(cornerRadius, (outerRadius - innerRadius)/2),
      padAngle: padAngle
    ));

  }

  return layouts;

}
