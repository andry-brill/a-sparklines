import 'package:flutter/material.dart';
import 'package:sparklines/src/data/data_point.dart';
import 'package:sparklines/src/interfaces.dart';
import 'package:vector_math/vector_math_64.dart';

import '../../data/line_data.dart';
import 'base_line_type_renderer.dart';

/// Renders linear (straight line) connections between points
class LinearLineRenderer extends BaseLineTypeRenderer<LinearLineData> {

  const LinearLineRenderer();

  @override
  Path toLinePath(LinearLineData lineType, Path path, List<DataPoint> points, {bool useFy = true, bool reverse = false}) {

    if (reverse) {
      for (int i = points.length - 2; i >= 0; i--) {
        final point = points[i];
        path.lineTo(point.x, point.getYorFY(useFy));
      }
    } else {
      for (int i = 1; i < points.length; i++) {
        final point = points[i];
        path.lineTo(point.x, point.getYorFY(useFy));
      }
    }

    return path;
  }

  @override
  void renderComplexPath(ChartRenderContext context, LineData lineData, bool isDynamicStroke, bool isDynamicPaint) {
    if (!renderDynamicPaint(context, lineData, isDynamicStroke, isDynamicPaint)) {

      final points = lineData.points;

      final globalSize = lineData.thickness.size;
      final globalHalfScreen = context.toScreenLength(globalSize) / 2;

      // ---- transform centerline to screen space ----

      final center = points.map((p) {
        final v = context.pathTransform.transform3(Vector3(p.x, p.fy, 0));
        return Offset(v.x, v.y);
      }).toList();

      final count = center.length;

      // ---- compute extra half thickness per point ----

      final halfExtra = List<double>.generate(count, (i) {

        final localSize = points[i].thickness?.size ?? globalSize;
        final localHalf = context.toScreenLength(localSize) / 2;

        return (localHalf - globalHalfScreen).clamp(0.0, double.infinity);
      });

      // ---- compute normals per segment ----

      final normals = <Offset>[];

      for (int i = 0; i < count - 1; i++) {

        final d = center[i + 1] - center[i];
        final len = d.distance;

        if (len <= 0.00001) {
          normals.add(const Offset(0, 0));
          continue;
        }

        final dir = d / len;

        normals.add(Offset(-dir.dy, dir.dx));
      }

      // ---- intersection helper ----

      Offset intersectLines(
          Offset p,
          Offset r,
          Offset q,
          Offset s,
          ) {

        final cross = r.dx * s.dy - r.dy * s.dx;

        if (cross.abs() < 0.00001) {
          return p;
        }

        final qp = q - p;

        final t = (qp.dx * s.dy - qp.dy * s.dx) / cross;

        return p + r * t;
      }

      // ---- build contours ----

      final top = <Offset>[];
      final bottom = <Offset>[];

      // first point
          {
        final n = normals.first;
        final h = halfExtra.first;

        top.add(center.first + n * h);
        bottom.add(center.first - n * h);
      }

      // interior points
      for (int i = 1; i < count - 1; i++) {

        final nPrev = normals[i - 1];
        final nNext = normals[i];

        final hPrev = halfExtra[i];
        final hNext = halfExtra[i];

        final topPrevPoint = center[i] + nPrev * hPrev;
        final topNextPoint = center[i] + nNext * hNext;

        final bottomPrevPoint = center[i] - nPrev * hPrev;
        final bottomNextPoint = center[i] - nNext * hNext;

        final dirPrev = center[i] - center[i - 1];
        final dirNext = center[i + 1] - center[i];

        final topJoin = intersectLines(
          topPrevPoint,
          dirPrev,
          topNextPoint,
          dirNext,
        );

        final bottomJoin = intersectLines(
          bottomPrevPoint,
          dirPrev,
          bottomNextPoint,
          dirNext,
        );

        top.add(topJoin);
        bottom.add(bottomJoin);
      }

      // last point
          {
        final n = normals.last;
        final h = halfExtra.last;

        top.add(center.last + n * h);
        bottom.add(center.last - n * h);
      }

      // ---- build final path ----

      final path = Path();

      path.moveTo(top.first.dx, top.first.dy);

      for (int i = 1; i < top.length; i++) {
        path.lineTo(top[i].dx, top[i].dy);
      }

      for (int i = bottom.length - 1; i >= 0; i--) {
        path.lineTo(bottom[i].dx, bottom[i].dy);
      }

      path.close();

      final bounds = path.getBounds();

      final fillPaint = buildFillPaint(context, lineData);
      final strokePaint = buildStrokePaint(context, lineData);

      if (isDynamicStroke) {
        Gradient global = globalMixedGradient(lineData.thickness, lineData.points);
        strokePaint.shader = fillPaint.shader = global.createShader(bounds);
      } else {
        paintThickness(fillPaint, bounds, lineData.thickness);
        paintThickness(strokePaint, bounds, lineData.thickness);
      }

      context.canvas.drawPath(path, fillPaint);
      context.canvas.drawPath(path, strokePaint);
    }
  }
}
