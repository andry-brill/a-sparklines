import 'package:flutter/material.dart';
import 'package:sparklines/src/data/data_point.dart';
import 'package:sparklines/src/interfaces.dart';

import '../../data/line_data.dart';
import 'base_line_type_renderer.dart';

/// Renders curved (smooth) line connections between points
class CurvedLineRenderer extends BaseLineTypeRenderer<CurvedLineData> {

  const CurvedLineRenderer();

  @override
  Path toLinePath(
      CurvedLineData lineType,
      Path path,
      List<DataPoint> points, {
        bool useFy = true,
        bool reverse = false,
      }) {
    if (points.isEmpty) return path;
    if (points.length == 1) {
      final p = points.first;
      path.moveTo(p.x, p.getYorFY(useFy));
      return path;
    }

    final s = lineType.smoothness.clamp(0.0, 1.0);

    if (reverse) {
      _buildReverse(path, points, s, useFy);
    } else {
      _buildForward(path, points, s, useFy);
    }

    return path;
  }

  void _buildForward(
      Path path,
      List<DataPoint> points,
      double smoothness,
      bool useFy,
      ) {
    final count = points.length;

    final first = points.first;
    path.moveTo(first.x, first.getYorFY(useFy));

    for (int i = 0; i < count - 1; i++) {
      final p0 = i > 0 ? points[i - 1] : points[i];
      final p1 = points[i];
      final p2 = points[i + 1];
      final p3 = i < count - 2 ? points[i + 2] : p2;

      final cp1x =
          p1.x + (p2.x - p0.x) * smoothness / 6.0;
      final cp1y =
          p1.getYorFY(useFy) +
              (p2.getYorFY(useFy) - p0.getYorFY(useFy)) *
                  smoothness /
                  6.0;

      final cp2x =
          p2.x - (p3.x - p1.x) * smoothness / 6.0;
      final cp2y =
          p2.getYorFY(useFy) -
              (p3.getYorFY(useFy) - p1.getYorFY(useFy)) *
                  smoothness /
                  6.0;

      path.cubicTo(
        cp1x,
        cp1y,
        cp2x,
        cp2y,
        p2.x,
        p2.getYorFY(useFy),
      );
    }
  }

  void _buildReverse(
      Path path,
      List<DataPoint> points,
      double smoothness,
      bool useFy,
      ) {
    final count = points.length;

    final last = points.last;
    path.moveTo(last.x, last.getYorFY(useFy));

    for (int i = count - 1; i > 0; i--) {
      final p0 = i < count - 1 ? points[i + 1] : points[i];
      final p1 = points[i];
      final p2 = points[i - 1];
      final p3 = i > 1 ? points[i - 2] : p2;

      final cp1x =
          p1.x + (p2.x - p0.x) * smoothness / 6.0;
      final cp1y =
          p1.getYorFY(useFy) +
              (p2.getYorFY(useFy) - p0.getYorFY(useFy)) *
                  smoothness /
                  6.0;

      final cp2x =
          p2.x - (p3.x - p1.x) * smoothness / 6.0;
      final cp2y =
          p2.getYorFY(useFy) -
              (p3.getYorFY(useFy) - p1.getYorFY(useFy)) *
                  smoothness /
                  6.0;

      path.cubicTo(
        cp1x,
        cp1y,
        cp2x,
        cp2y,
        p2.x,
        p2.getYorFY(useFy),
      );
    }
  }

  @override
  void renderComplexPath(Canvas canvas, ChartRenderContext context, LineData lineData, bool isDynamicStroke, bool isDynamicPaint) {
    if (!renderDynamicPaint(canvas, context, lineData, isDynamicStroke, isDynamicPaint)) {
      // NB! Dynamic thickness not supported yet
      renderSimplePath(canvas, context, lineData);
    }
  }
}
