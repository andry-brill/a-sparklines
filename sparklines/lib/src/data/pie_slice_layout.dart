import 'dart:math' as math;
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:sparklines/src/layout/circle_arc_builder.dart';
import 'data_point.dart';

/// Result of computing layout for a single pie slice (angle order, radii, space).
class PieSliceLayout {

  final double startAngle;
  final double endAngle;
  final double innerRadius;
  final double outerRadius;
  final Offset offset;
  final double cornerRadius;

  final DataPoint point;

  const PieSliceLayout({
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
/// - Each point (x,y) defines arc, where r = x, startAngle = y - dy, deltaAngle = dy, (y + dy = fy = endAngle)
///   - mid point (x=10, y=0rad) == (x=10, y=0)
/// - innerRadius = x - thicknessAlignedLeft, outerRadius = x + thicknessAlignedRight based on thicknessAlign.
/// - space = uniform linear gap between slices, must be set as spaceOffset (aligned with "angle" of axis-ray)
List<PieSliceLayout> computePieLayouts(
  List<DataPoint> points,
  double space,
  double thickness,
  double thicknessAlign,
  double cornerRadius,
) {
  return points.where((point) => point.x > 0 && thickness > 0).map((point) {

    // align: 0 = sweep/2 each side; -1 = all "left"; +1 = all "right" (same as bar)
    final halfThicknessLeft = thickness * (1 + thicknessAlign) / 2;
    final halfSweepRight = thickness * (1 - thicknessAlign) / 2;

    final innerRadius = max(0.0, point.x - halfThicknessLeft);
    final outerRadius = point.x + halfSweepRight;

    final angle = point.y;
    final startAngle = angle - point.dy;
    final endAngle = angle + point.dy;

    final spaceHalf = space / 2;
    final spaceOffset = Offset(
      spaceHalf * math.cos(angle),
      spaceHalf * math.sin(angle),
    );

    return PieSliceLayout(
      startAngle: startAngle,
      endAngle: endAngle,
      innerRadius: innerRadius,
      outerRadius: outerRadius,
      offset: spaceOffset,
      point: point,
      cornerRadius: cornerRadius
    );

  }).toList();
}
