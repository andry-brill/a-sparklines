import 'dart:math' as math;
import 'dart:math';
import 'package:flutter/material.dart';
import 'data_point.dart';
import 'package:vector_math/vector_math_64.dart';

class CircleArc {

  final double startAngle;
  final double endAngle;
  final double radius;
  final Offset center;

  const CircleArc({required this.startAngle, required this.endAngle, required this.radius, required this.center});

  EllipseArc transform(Matrix4 transform) => transformArc(this, transform);

  static EllipseArc transformArc(CircleArc arc, Matrix4 transform) {
    final Vector3 c = transform.transform3(
      Vector3(arc.center.dx, arc.center.dy, 0),
    );

    // Transform basis vectors scaled by radius
    final Vector3 vx = transform.transform3(
      Vector3(arc.center.dx + arc.radius, arc.center.dy, 0),
    );

    final Vector3 vy = transform.transform3(
      Vector3(arc.center.dx, arc.center.dy + arc.radius, 0),
    );

    // Axis vectors are relative to center
    final Offset center = Offset(c.x, c.y);

    final Offset axisX = Offset(vx.x - c.x, vx.y - c.y);
    final Offset axisY = Offset(vy.x - c.x, vy.y - c.y);

    return EllipseArc(
      center: center,
      axisX: axisX,
      axisY: axisY,
      startAngle: arc.startAngle,
      endAngle: arc.endAngle,
    );
  }
}

class EllipseArc {

  final double startAngle;
  final double endAngle;
  final Offset axisX;   // transformed (radius, 0)
  final Offset axisY;   // transformed (0, radius)
  final Offset center;

  const EllipseArc({required this.startAngle, required this.endAngle, required this.axisX, required this.axisY, required this.center});

}

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

  CircleArc toArc({ double align = 0.0 }) {
    final t = (align + 1) / 2;
    final r = innerRadius + (outerRadius - innerRadius) * t.clamp(0.0, 1.0);
    return CircleArc(startAngle: startAngle, endAngle: endAngle, radius: r, center: offset);
  }

  /// Bounds of the arc at radius interpolated by [align].
  /// [align]: -1 = innerRadius, 0 = mid-radius, 1 = outerRadius.
  Rect arcBounds({ double align = 0.0 }) {

    final t = (align + 1) / 2;
    final r = innerRadius + (outerRadius - innerRadius) * t.clamp(0.0, 1.0);

    double? minX, maxX, minY, maxY;

    void add(double x, double y) {
      minX = math.min(minX ?? x, x);
      maxX = math.max(maxX ?? x, x);
      minY = math.min(minY ?? y, y);
      maxY = math.max(maxY ?? y, y);
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

    return Rect.fromLTRB(minX!, minY!, maxX!, maxY!).shift(offset);
  }

  /// Builds a simple arc path from [startAngle] to [endAngle].
  /// [align]: -1 = innerRadius, 0 = mid-radius, 1 = outerRadius.
  /// [origin] is the arc center (default layout origin).
  Path? arcPath({
    double align = 0.0,
    String? debug
  }) {

    final t = (align + 1) / 2;
    final r = innerRadius + (outerRadius - innerRadius) * t.clamp(0.0, 1.0);

    final path = Path();
    final center = offset;

    if (r.abs() < 1e-10) {
      return null;
    }

    final sweep = endAngle - startAngle;
    final startX = center.dx + r * math.cos(startAngle);
    final startY = center.dy + r * math.sin(startAngle);

    path.moveTo(startX, startY);

    if (debug != null) {
      debugPrint('$debug from: ($startX, $startY)');
    }

    path.arcTo(
      Rect.fromCircle(center: center, radius: r),
      startAngle,
      sweep,
      false,
    );

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
  String? debug
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
    );

  }).toList();
}
