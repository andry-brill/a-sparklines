import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'data_point.dart';

/// Result of computing layout for a single pie slice (angle order, radii, space).
class PieSliceLayout {
  final double startAngle;
  final double endAngle;
  final double innerRadius;
  final double outerRadius;
  final Offset spaceOffset;
  final DataPoint point;

  const PieSliceLayout({
    required this.startAngle,
    required this.endAngle,
    required this.innerRadius,
    required this.outerRadius,
    required this.spaceOffset,
    required this.point,
  });
}

/// Computes slice layout for pie chart.
/// - Each point (x,y) defines axis-ray from (0,0); (x,y) must not be (0,0).
/// - innerRadius = |(x,y)|, outerRadius = innerRadius + dy.
/// - [align]: 0 = (sweep/2) on each side of axis ray; !=0 splits left/right (ThicknessData.align).
/// - space = uniform linear gap between slices, must be set as spaceOffset (aligned with "angle" of axis-ray)
List<PieSliceLayout> computePieSliceLayout(
  List<DataPoint> points,
  double space,
  double sweepRadians,
  double align,
) {
  return points.map((point) {

    return PieSliceLayout();
  }).toList();
}

/// Bounding box of a sector (radians, math coords: x right, y up).
void sectorBounds(
  double startAngle,
  double endAngle,
  double innerRadius,
  double outerRadius,
  Offset offset,
  void Function(double minX, double maxX, double minY, double maxY) use,
) {
  double minX = 0.0, maxX = 0.0, minY = 0.0, maxY = 0.0;

  void add(double x, double y) {
    minX = math.min(minX, x);
    maxX = math.max(maxX, x);
    minY = math.min(minY, y);
    maxY = math.max(maxY, y);
  }

  add(innerRadius * math.cos(startAngle), innerRadius * math.sin(startAngle));
  add(innerRadius * math.cos(endAngle), innerRadius * math.sin(endAngle));
  add(outerRadius * math.cos(startAngle), outerRadius * math.sin(startAngle));
  add(outerRadius * math.cos(endAngle), outerRadius * math.sin(endAngle));

  if (innerRadius > 0) add(0, 0);

  final sweep = endAngle - startAngle;
  if (sweep >= 2 * math.pi) {
    add(-outerRadius, -outerRadius);
    add(outerRadius, outerRadius);
  } else {
    final mod = (double a, double b) => ((a % b) + b) % b;
    final toPos = (double angle) => mod(angle, 2 * math.pi);
    final s = toPos(startAngle);
    final e = toPos(endAngle);
    final crosses = (double bound) {
      if (s <= e) return s < bound && bound < e;
      return s < bound || bound < e;
    };
    if (crosses(0)) add(outerRadius, 0);
    if (crosses(math.pi)) add(-outerRadius, 0);
    if (crosses(math.pi / 2)) add(0, outerRadius);
    if (crosses(3 * math.pi / 2)) add(0, -outerRadius);
  }

  use(minX + offset.dx, maxX + offset.dx, minY + offset.dy, maxY + offset.dy);
}
