import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart';
import 'package:sparklines/src/data/pie_data.dart';
import 'package:sparklines/src/data/pie_slice_layout.dart';
import 'package:sparklines/src/interfaces.dart';
import 'package:sparklines/src/layout/arc_builder.dart';
import 'package:sparklines/src/renderers/chart_renderer.dart';

/// Screen-space arc layout: center, radii, and angles derived from transformed axis.
typedef _ScreenArcLayout = ({
  Offset center,
  double innerRadius,
  double outerRadius,
  double startAngle,
  double endAngle,
});

/// Renders pie charts.
/// Arc axis (center arc at mid-radius) is transformed to screen space; thickness
/// is applied in screen space so it stays uniform (like bars).
class PieChartRenderer extends AChartRenderer<PieData> {

  @override
  void renderData(
    ChartRenderContext context,
    PieData pieData,
  ) {

    final layouts = computePieLayouts(
      pieData.points,
      pieData.space,
      pieData.thickness.size,
      pieData.thickness.align,
    );

    final paint = Paint();
    final thickness = pieData.thickness;

    for (final layout in layouts) {
      final arcThickness = layout.outerRadius - layout.innerRadius;
      final screenThickness = context.toScreenLength(arcThickness);
      final align = thickness.align;

      Path arc = layout.arcPath();
      arc = arc.transform(context.pathTransform.storage);

      final axis = toArcPoints(arc);
      final pieLayout = resolveArcLayout(screenThickness, align, axis);

      Path piePath = buildPiePath(pieData.borderRadius, context, pieLayout);

      paint.style = PaintingStyle.fill;

      final shaderRect = piePath.getBounds();
      if (thickness.gradient != null) {
        paint.shader = thickness.gradient!.createShader(shaderRect);
      } else {
        paint.shader = null;
        paint.color = thickness.color;
      }

      context.canvas.drawPath(piePath, paint);

      final border = pieData.border;
      if (border != null) {
        final borderSize = context.toScreenLength(border.size);
        final borderLayout = (
          center: pieLayout.center,
          innerRadius: pieLayout.innerRadius - borderSize * border.align,
          outerRadius: pieLayout.outerRadius + borderSize * border.align,
          startAngle: pieLayout.startAngle,
          endAngle: pieLayout.endAngle,
        );
        Path pieBorderPath = buildPiePath(pieData.borderRadius, context, borderLayout);

        paint.style = PaintingStyle.stroke;
        paint.strokeWidth = borderSize;

        if (border.gradient != null) {
          paint.shader = border.gradient!.createShader(pieBorderPath.getBounds());
        } else {
          paint.shader = null;
          paint.color = border.color;
        }

        context.canvas.drawPath(pieBorderPath, paint);
      }
    }

    drawDataPoints(paint, context, pieData, pieData.points);
  }

  /// Resolves center, radii, and angles from transformed axis arc points.
  _ScreenArcLayout resolveArcLayout(
    double thickness,
    double align,
    (Offset, Offset, Offset) axisArcPoints,
  ) {
    final (start, mid, end) = axisArcPoints;

    final center = _circumcenter(start, mid, end);
    final radius = _distance(center, mid);

    final half = thickness / 2;
    final a = half * (1 + align);
    final b = half * (1 - align);

    final startAngle = math.atan2(
      start.dy - center.dy,
      start.dx - center.dx,
    );
    final endAngle = math.atan2(
      end.dy - center.dy,
      end.dx - center.dx,
    );

    return (
      center: center,
      innerRadius: math.max(0, radius - b),
      outerRadius: radius + a,
      startAngle: startAngle,
      endAngle: endAngle,
    );
  }

  /// Builds filled arc path using [ArcBuilder] with uniform thickness in screen space.
  Path buildPiePath(
    double? borderRadius,
    ChartRenderContext context,
    _ScreenArcLayout layout,
  ) {
    final cornerRadius = borderRadius != null
        ? context.toScreenLength(borderRadius)
        : 0.0;

    final arcBuilder = ArcBuilder(
      innerRadius: layout.innerRadius,
      outerRadius: layout.outerRadius,
      startAngle: layout.startAngle,
      endAngle: layout.endAngle,
      padAngle: 0.0,
      cornerRadius: cornerRadius,
    );

    // ArcBuilder uses math coords (y up); flip y for screen (y down)
    final path = arcBuilder.build();
    return path//.transform(arcBuilderAlign.storage)
        .shift(layout.center);
  }

  static final arcBuilderAlign = Matrix4.identity()..scaleByVector3(Vector3(1.0, -1.0, 1.0));

  static Offset _circumcenter(Offset a, Offset b, Offset c) {
    final ax = a.dx, ay = a.dy;
    final bx = b.dx, by = b.dy;
    final cx = c.dx, cy = c.dy;
    final d = 2 * (ax * (by - cy) + bx * (cy - ay) + cx * (ay - by));
    if (d.abs() < 1e-10) return Offset((ax + bx + cx) / 3, (ay + by + cy) / 3);
    final ux = ((ax * ax + ay * ay) * (by - cy) +
            (bx * bx + by * by) * (cy - ay) +
            (cx * cx + cy * cy) * (ay - by)) /
        d;
    final uy = ((ax * ax + ay * ay) * (cx - bx) +
            (bx * bx + by * by) * (ax - cx) +
            (cx * cx + cy * cy) * (bx - ax)) /
        d;
    return Offset(ux, uy);
  }

  static double _distance(Offset a, Offset b) {
    final dx = b.dx - a.dx;
    final dy = b.dy - a.dy;
    return math.sqrt(dx * dx + dy * dy);
  }

  (Offset, Offset, Offset) toArcPoints(Path arcPath) {
    final metric = arcPath.computeMetrics().first;
    final double len = metric.length;

    final Offset start = metric.getTangentForOffset(0.0)?.position ?? Offset.zero;
    final Offset mid = metric.getTangentForOffset(len / 2)?.position ?? Offset.zero;
    final Offset end = metric.getTangentForOffset(len)?.position ?? Offset.zero;

    return (start, mid, end);
  }
}
