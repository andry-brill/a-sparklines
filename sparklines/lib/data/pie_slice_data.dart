import 'dart:math';
import 'package:flutter/material.dart';
import '../interfaces/chart_transform.dart';
import '../interfaces/length_value.dart';
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
      startAngle: startAngle + pi / 2,
      endAngle: endAngle + pi / 2,
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
/// - [eps] is the minimum radius, thickness, and angular span to include.
List<PieSliceData> computePies(
  List<DataPoint> pies,
  double offset,
  double padAngle,
  ThicknessData thickness,
  ILengthValue? radius,
  ChartTransform transform, {
  double eps = 0.0001,
}) {
  List<PieSliceData> layouts = [];

  for (var pie in pies) {
    final borderRadius = pie.border?.borderRadius ?? radius;
    final cornerRadius = borderRadius == null
        ? 0.0
        : transform.antiScalar(transform.length(borderRadius));

    final thicknessAlign = pie.thickness?.align ?? thickness.align;
    final thicknessValue = pie.thickness?.size ?? thickness.size;
    final thicknessSize =
        transform.antiScalar(transform.length(thicknessValue));

    if (pie.x <= eps || thicknessSize <= eps || pie.dy <= eps) {
      continue;
    }

    final halfInnerThickness = thicknessSize * (1 - thicknessAlign) / 2;
    final halfOuterThickness = thicknessSize * (1 + thicknessAlign) / 2;

    final innerRadius = max(0.0, pie.x - halfInnerThickness);
    final outerRadius = pie.x + halfOuterThickness;

    final pointDx = pie.pieOffset?.pieOffset ?? offset;
    final spaceOffset = toCartesian(pointDx, pie);

    layouts.add(PieSliceData(
        startAngle: pie.y,
        endAngle: pie.fy,
        innerRadius: innerRadius,
        outerRadius: outerRadius,
        offset: spaceOffset,
        point: pie,
        cornerRadius: min(cornerRadius, (outerRadius - innerRadius) / 2),
        padAngle: padAngle));
  }

  return layouts;
}

/// Data-space bounds of pie centerlines and offsets.
///
/// Visual thickness, borders, corner radii, and markers are intentionally not
/// included, matching the bounds behavior of line and bar charts.
/// [eps] is the minimum radius and angular span to include.
Rect computePieDataBounds(
  List<DataPoint> pies,
  double offset, {
  double eps = 0.0001,
}) {
  Rect? bounds;

  for (final pie in pies) {
    if (pie.x <= eps || pie.dy <= eps) {
      continue;
    }

    final center = toCartesian(pie.pieOffset?.pieOffset ?? offset, pie);
    final start = pie.y;
    final end = pie.fy;
    final angles = <double>[start, end];

    if (end - start >= 2 * pi) {
      angles.addAll(const [0.0, pi / 2, pi, 3 * pi / 2]);
    } else {
      final firstQuarter = (start / (pi / 2)).ceil();
      final lastQuarter = (end / (pi / 2)).floor();
      for (var quarter = firstQuarter; quarter <= lastQuarter; quarter++) {
        angles.add(quarter * pi / 2);
      }
    }

    for (final angle in angles) {
      final point = center + Offset(pie.x * cos(angle), pie.x * sin(angle));
      final pointBounds = Rect.fromLTWH(point.dx, point.dy, 0, 0);
      bounds =
          bounds == null ? pointBounds : bounds.expandToInclude(pointBounds);
    }
  }

  return bounds ?? const Rect.fromLTRB(0, 0, 1, 1);
}
