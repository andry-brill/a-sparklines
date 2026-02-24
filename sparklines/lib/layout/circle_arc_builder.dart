import 'dart:math' as math;
import 'dart:ui';

const _epsilon = 0.001;

class CircleArcBuilder {

  final double innerRadius;
  final double outerRadius;
  final double startAngle;
  final double endAngle;
  final double padAngle;
  final double cornerRadius;
  final double? padRadius;

  CircleArcBuilder({
    this.innerRadius = 0.0,
    this.outerRadius = 0.0,
    this.startAngle = 0.0,
    this.endAngle = 0.0,
    this.padAngle = 0.0,
    this.cornerRadius = 0.0,
    this.padRadius,
  });

  Offset centroid() {
    final r = (innerRadius.abs() + outerRadius.abs()) / 2.0;
    final a = (startAngle + endAngle) / 2.0 - math.pi / 2.0;
    return Offset(math.cos(a) * r, math.sin(a) * r);
  }

  static const double _tau = 2 * math.pi;

  Path build() {

    final path = Path();

    double r0 = innerRadius;
    double r1 = outerRadius;
    double a0 = startAngle - math.pi / 2.0;
    double a1 = endAngle - math.pi / 2.0;
    double da = (a1 - a0).abs();
    bool cw = a1 > a0;

    if (r1 < r0) {
      final tmp = r1;
      r1 = r0;
      r0 = tmp;
    }

    if (!(r1 > _epsilon)) {
      path.moveTo(0, 0);
      return path;
    }

    if (da > _tau - _epsilon) {
      path.moveTo(r1 * math.cos(a0), r1 * math.sin(a0));
      _arcSegment(path, 0, 0, r1, a0, a1, !cw);

      if (r0 > _epsilon) {
        path.moveTo(r0 * math.cos(a1), r0 * math.sin(a1));
        _arcSegment(path, 0, 0, r0, a1, a0, cw);
      }

      path.close();
      return path;
    }

    double a01 = a0;
    double a11 = a1;
    double a00 = a0;
    double a10 = a1;
    double da0 = da;
    double da1 = da;

    final ap = padAngle / 2.0;
    final rp = (ap > _epsilon)
        ? (padRadius ?? math.sqrt(r0 * r0 + r1 * r1))
        : null;

    final rc = math.min((r1 - r0).abs() / 2.0, cornerRadius.abs());
    double rc0 = rc;
    double rc1 = rc;

    Map<String, double>? t0;
    Map<String, double>? t1;

    if (rp != null && rp > _epsilon) {
      double p0 = math.asin(rp / r0 * math.sin(ap));
      double p1 = math.asin(rp / r1 * math.sin(ap));

      if ((da0 -= p0 * 2) > _epsilon) {
        p0 *= (cw ? 1 : -1);
        a00 += p0;
        a10 -= p0;
      } else {
        da0 = 0;
        a00 = a10 = (a0 + a1) / 2.0;
      }

      if ((da1 -= p1 * 2) > _epsilon) {
        p1 *= (cw ? 1 : -1);
        a01 += p1;
        a11 -= p1;
      } else {
        da1 = 0;
        a01 = a11 = (a0 + a1) / 2.0;
      }
    }

    final x01 = r1 * math.cos(a01);
    final y01 = r1 * math.sin(a01);
    final x10 = r0 * math.cos(a10);
    final y10 = r0 * math.sin(a10);

    if (rc > _epsilon) {
      final x11 = r1 * math.cos(a11);
      final y11 = r1 * math.sin(a11);
      final x00 = r0 * math.cos(a00);
      final y00 = r0 * math.sin(a00);

      if (da < math.pi) {
        final oc = _intersect(
          x01,
          y01,
          x00,
          y00,
          x11,
          y11,
          x10,
          y10,
        );

        if (oc != null) {
          final ax = x01 - oc.dx;
          final ay = y01 - oc.dy;
          final bx = x11 - oc.dx;
          final by = y11 - oc.dy;

          double dot = (ax * bx + ay * by) /
              (math.sqrt(ax * ax + ay * ay) *
                  math.sqrt(bx * bx + by * by));

          dot = dot.clamp(-1.0, 1.0);

          final kc = 1 / math.sin(math.acos(dot) / 2.0);
          final lc = math.sqrt(oc.dx * oc.dx + oc.dy * oc.dy);

          rc0 = math.min(rc, (r0 - lc) / (kc - 1));
          rc1 = math.min(rc, (r1 - lc) / (kc + 1));
        } else {
          rc0 = 0;
          rc1 = 0;
        }
      }
    }

    if (!(da1 > _epsilon)) {
      path.moveTo(x01, y01);
      path.close();
      return path;
    }

    if (rc1 > _epsilon) {
      final x11 = r1 * math.cos(a11);
      final y11 = r1 * math.sin(a11);
      final x00 = r0 * math.cos(a00);
      final y00 = r0 * math.sin(a00);

      t0 = _cornerTangents(x00, y00, x01, y01, r1, rc1, cw);
      t1 = _cornerTangents(x11, y11, x10, y10, r1, rc1, cw);

      path.moveTo(t0['cx']! + t0['x01']!, t0['cy']! + t0['y01']!);

      final t0Angle01 = math.atan2(t0['y01']!, t0['x01']!);
      final t1Angle01 = math.atan2(t1['y01']!, t1['x01']!);
      final t0Angle11 = math.atan2(t0['y11']!, t0['x11']!);
      final t1Angle11 = math.atan2(t1['y11']!, t1['x11']!);

      if (rc1 < rc) {
        _arcSegment(path, t0['cx']!, t0['cy']!, rc1, t0Angle01, t1Angle01, !cw);
      } else {
        _arcSegment(path, t0['cx']!, t0['cy']!, rc1, t0Angle01, t0Angle11, !cw);
        _arcSegment(
            path,
            0,
            0,
            r1,
            math.atan2(t0['cy']! + t0['y11']!, t0['cx']! + t0['x11']!),
            math.atan2(t1['cy']! + t1['y11']!, t1['cx']! + t1['x11']!),
            !cw);
        _arcSegment(path, t1['cx']!, t1['cy']!, rc1, t1Angle11, t1Angle01, !cw);
      }
    } else {
      path.moveTo(x01, y01);
      _arcSegment(path, 0, 0, r1, a01, a11, !cw);
    }

    if (!(r0 > _epsilon) || !(da0 > _epsilon)) {
      path.lineTo(x10, y10);
    } else if (rc0 > _epsilon) {
      final x11 = r1 * math.cos(a11);
      final y11 = r1 * math.sin(a11);
      final x00 = r0 * math.cos(a00);
      final y00 = r0 * math.sin(a00);

      t0 = _cornerTangents(x10, y10, x11, y11, r0, -rc0, cw);
      t1 = _cornerTangents(x01, y01, x00, y00, r0, -rc0, cw);

      path.lineTo(t0['cx']! + t0['x01']!, t0['cy']! + t0['y01']!);

      final t0Angle01 = math.atan2(t0['y01']!, t0['x01']!);
      final t1Angle01 = math.atan2(t1['y01']!, t1['x01']!);
      final t0Angle11 = math.atan2(t0['y11']!, t0['x11']!);
      final t1Angle11 = math.atan2(t1['y11']!, t1['x11']!);

      if (rc0 < rc) {
        _arcSegment(path, t0['cx']!, t0['cy']!, rc0, t0Angle01, t1Angle01, !cw);
      } else {
        _arcSegment(path, t0['cx']!, t0['cy']!, rc0, t0Angle01, t0Angle11, !cw);
        _arcSegment(
            path,
            0,
            0,
            r0,
            math.atan2(t0['cy']! + t0['y11']!, t0['cx']! + t0['x11']!),
            math.atan2(t1['cy']! + t1['y11']!, t1['cx']! + t1['x11']!),
            cw);
        _arcSegment(path, t1['cx']!, t1['cy']!, rc0, t1Angle11, t1Angle01, !cw);
      }
    } else {
      _arcSegment(path, 0, 0, r0, a10, a00, cw);
    }

    path.close();
    return path;
  }

  static Offset? _intersect(
      double x0,
      double y0,
      double x1,
      double y1,
      double x2,
      double y2,
      double x3,
      double y3) {
    final x10 = x1 - x0;
    final y10 = y1 - y0;
    final x32 = x3 - x2;
    final y32 = y3 - y2;
    double t = y32 * x10 - x32 * y10;
    if (t * t < _epsilon) return null;
    t = (x32 * (y0 - y2) - y32 * (x0 - x2)) / t;
    return Offset(x0 + t * x10, y0 + t * y10);
  }

  static Map<String, double> _cornerTangents(
      double x0,
      double y0,
      double x1,
      double y1,
      double r1,
      double rc,
      bool cw) {
    final x01 = x0 - x1;
    final y01 = y0 - y1;
    final lo = (cw ? rc : -rc) / math.sqrt(x01 * x01 + y01 * y01);
    final ox = lo * y01;
    final oy = -lo * x01;
    final x11 = x0 + ox;
    final y11 = y0 + oy;
    final x10 = x1 + ox;
    final y10 = y1 + oy;
    final x00 = (x11 + x10) / 2.0;
    final y00 = (y11 + y10) / 2.0;
    final dx = x10 - x11;
    final dy = y10 - y11;
    final d2 = dx * dx + dy * dy;
    final r = r1 - rc;
    final D = x11 * y10 - x10 * y11;
    final d = (dy < 0 ? -1 : 1) *
        math.sqrt(math.max(0, r * r * d2 - D * D));
    double cx0 = (D * dy - dx * d) / d2;
    double cy0 = (-D * dx - dy * d) / d2;
    final cx1 = (D * dy + dx * d) / d2;
    final cy1 = (-D * dx + dy * d) / d2;
    final dx0 = cx0 - x00;
    final dy0 = cy0 - y00;
    final dx1 = cx1 - x00;
    final dy1 = cy1 - y00;

    if (dx0 * dx0 + dy0 * dy0 >
        dx1 * dx1 + dy1 * dy1) {
      cx0 = cx1;
      cy0 = cy1;
    }

    final rRatio = r1 / r;
    return {
      'cx': cx0,
      'cy': cy0,
      'x01': -ox,
      'y01': -oy,
      'x11': cx0 * (rRatio - 1),
      'y11': cy0 * (rRatio - 1),
    };
  }

  static void _arcSegment(
      Path path,
      double cx,
      double cy,
      double r,
      double a0,
      double a1,
      bool anticlockwise) {
    if (r <= 0) return;

    double da = a1 - a0;

    if (!anticlockwise && da < 0) {
      da += _tau;
    } else if (anticlockwise && da > 0) {
      da -= _tau;
    }

    if (da.abs() < _epsilon) return;

    final rect = Rect.fromCircle(
      center: Offset(cx, cy),
      radius: r,
    );

    path.arcTo(rect, a0, da, false);
  }
}
