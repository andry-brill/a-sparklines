import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'data_point.dart';

/// Result of computing layout for a single pie slice (angle order, radii, space).
class PieSliceLayout {
  final int index;
  final double startAngle;
  final double endAngle;
  final double innerRadius;
  final double outerRadius;
  final Offset spaceOffset;
  final DataPoint point;

  const PieSliceLayout({
    required this.index,
    required this.startAngle,
    required this.endAngle,
    required this.innerRadius,
    required this.outerRadius,
    required this.spaceOffset,
    required this.point,
  });
}

/// Computes ordered slice layout for pie chart.
/// - Each point (x,y) defines ray from (0,0); (x,y) must not be (0,0).
/// - innerRadius = |(x,y)|, outerRadius = innerRadius + dy.
/// - Slices sorted by angle = atan2(y,x). Angle ranges assigned by proportion of dy.
/// - [sweepRadians]: total sweep of the pie in radians (e.g. 2*pi for full circle).
/// - [align]: 0 = (sweep/2) on each side of axis ray; !=0 splits left/right (ThicknessData.align).
/// - space = uniform linear gap between slices; gap_rad = space / maxOuterRadius.
///
/// Layout is computed in data space.
List<PieSliceLayout> computePieSliceLayout(
  List<DataPoint> points,
  double space,
  double sweepRadians,
  double align,
) {
  if (points.isEmpty) return [];

  final workPoints = points;
  final workSpace = space;
  final workSweep = sweepRadians;
  final workAlign = align;

  final total = workPoints.fold<double>(0.0, (s, p) => s + p.dy);
  if (total <= 0) return [];

  final size = workSweep.isFinite && workSweep > 0 ? workSweep : 2 * math.pi;

  final indexed = <int, DataPoint>{};
  final angles = <int, double>{};
  final innerR = <int, double>{};
  final outerR = <int, double>{};

  for (int i = 0; i < workPoints.length; i++) {
    final p = workPoints[i];
    final r = math.sqrt(p.x * p.x + p.y * p.y);
    angles[i] = math.atan2(p.y, p.x);
    innerR[i] = r;
    outerR[i] = r + p.dy;
    indexed[i] = p;
  }

  final order = List<int>.from(List.generate(workPoints.length, (i) => i));
  order.sort((a, b) => angles[a]!.compareTo(angles[b]!));

  final maxOuter = order.map((i) => outerR[i]!).reduce(math.max);
  final gapRad = maxOuter > 0 && workSpace > 0 ? workSpace / maxOuter : 0.0;

  final n = order.length;
  final totalSweepAvailable = math.max(0.0, size - n * gapRad);

  final axis = angles[order[0]]!;
  final leftSweep = (1.0 - workAlign) * (size / 2);
  final rightSweep = (1.0 + workAlign) * (size / 2);
  final startAnglePie = axis - leftSweep;
  final endAnglePie = axis + rightSweep;

  double startAngle = startAnglePie + gapRad / 2;
  final result = <PieSliceLayout>[];
  final halfSpace = workSpace / 2;

  for (int k = 0; k < order.length; k++) {
    final i = order[k];
    final p = indexed[i]!;
    var effectiveSweep = (p.dy / total) * totalSweepAvailable;
    if (effectiveSweep <= 0) continue;

    final endAngleMax = endAnglePie - gapRad / 2;
    if (startAngle + effectiveSweep > endAngleMax) {
      effectiveSweep = math.max(0.0, endAngleMax - startAngle);
    }
    final endAngle = startAngle + effectiveSweep;
    final theta1 = startAngle;
    final theta2 = endAngle;
    final ox = halfSpace * (math.sin(theta2) - math.sin(theta1));
    final oy = halfSpace * (math.cos(theta1) - math.cos(theta2));

    result.add(PieSliceLayout(
      index: i,
      startAngle: startAngle,
      endAngle: endAngle,
      innerRadius: innerR[i]!,
      outerRadius: outerR[i]!,
      spaceOffset: Offset(ox, oy),
      point: p,
    ));

    startAngle = endAngle + gapRad;
  }

  return result;
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
