import 'dart:math' as math;
import 'dart:math';
import 'package:flutter/material.dart';
import 'data_point.dart';

/// Result of computing layout for a single pie slice (angle order, radii, space).
class PieSliceLayout {

  final double startAngle;
  final double endAngle;
  final double innerRadius;
  final double outerRadius;
  final Offset offset;
  final DataPoint point;

  const PieSliceLayout({
    required this.startAngle,
    required this.endAngle,
    required this.innerRadius,
    required this.outerRadius,
    required this.offset,
    required this.point,
  });

  /// Bounds of the arc at radius interpolated by [align].
  /// [align]: -1 = innerRadius, 0 = mid-radius, 1 = outerRadius.
  Rect arcBounds({ double align = 0.0 }) {

    final t = (align + 1) / 2;
    final r = innerRadius + (outerRadius - innerRadius) * t.clamp(0.0, 1.0);

    double minX = 0.0, maxX = 0.0, minY = 0.0, maxY = 0.0;

    void add(double x, double y) {
      minX = math.min(minX, x);
      maxX = math.max(maxX, x);
      minY = math.min(minY, y);
      maxY = math.max(maxY, y);
    }

    add(r * math.cos(startAngle), r * math.sin(startAngle));
    add(r * math.cos(endAngle), r * math.sin(endAngle));

    final sweep = endAngle - startAngle;
    if (sweep >= 2 * math.pi) {
      add(-r, -r);
      add(r, r);
    } else if (r > 0) {
      final mod = (double a, double b) => ((a % b) + b) % b;
      final toPos = (double angle) => mod(angle, 2 * math.pi);
      final s = toPos(startAngle);
      final e = toPos(endAngle);
      final crosses = (double bound) {
        if (s <= e) return s < bound && bound < e;
        return s < bound || bound < e;
      };
      if (crosses(0)) add(r, 0);
      if (crosses(math.pi)) add(-r, 0);
      if (crosses(math.pi / 2)) add(0, r);
      if (crosses(3 * math.pi / 2)) add(0, -r);
    }

    return Rect.fromLTRB(minX, minY, maxX, maxY).shift(offset);
  }
}

/// Computes slice layout for pie chart.
/// - Each point (x,y) defines arc, where r = x, startAngle = y - dy, deltaAngle = dy, (y + dy = fy = endAngle)
///   - making sure that point is in center on arc
/// - innerRadius = x - thicknessAlignedLeft, outerRadius = x + thicknessAlignedRight based on thicknessAlign.
/// - space = uniform linear gap between slices, must be set as spaceOffset (aligned with "angle" of axis-ray)
List<PieSliceLayout> computePieLayouts(
  List<DataPoint> points,
  double space,
  double thickness,
  double thicknessAlign,
) {
  return points.where((point) => point.x <= 0 || thickness <= 0).map((point) {

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
    );

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
