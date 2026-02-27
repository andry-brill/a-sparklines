import 'package:flutter/material.dart';
import '../../data/data_point.dart';
import '../../interfaces/chart_transform.dart';
import '../../interfaces/line_type.dart';
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
        bool reverse = false,
      }) {
    if (points.isEmpty) return path;
    if (points.length == 1) {
      final p = points.first;
      path.moveTo(p.x, p.fy);
      return path;
    }

    final s = lineType.smoothness.clamp(0.0, 1.0);

    if (reverse) {
      _buildReverse(path, points, s);
    } else {
      _buildForward(path, points, s);
    }

    return path;
  }

  void _buildForward(
      Path path,
      List<DataPoint> points,
      double smoothness,
      ) {
    final count = points.length;

    final first = points.first;
    path.moveTo(first.x, first.fy);

    for (int i = 0; i < count - 1; i++) {
      final p0 = i > 0 ? points[i - 1] : points[i];
      final p1 = points[i];
      final p2 = points[i + 1];
      final p3 = i < count - 2 ? points[i + 2] : p2;

      final cp1x =
          p1.x + (p2.x - p0.x) * smoothness / 6.0;
      final cp1y =
          p1.fy +
              (p2.fy - p0.fy) *
                  smoothness /
                  6.0;

      final cp2x =
          p2.x - (p3.x - p1.x) * smoothness / 6.0;
      final cp2y =
          p2.fy -
              (p3.fy - p1.fy) *
                  smoothness /
                  6.0;

      path.cubicTo(
        cp1x,
        cp1y,
        cp2x,
        cp2y,
        p2.x,
        p2.fy,
      );
    }
  }

  void _buildReverse(
      Path path,
      List<DataPoint> points,
      double smoothness,
      ) {

    final count = points.length;

    for (int i = count - 1; i > 0; i--) {
      final p0 = i < count - 1 ? points[i + 1] : points[i];
      final p1 = points[i];
      final p2 = points[i - 1];
      final p3 = i > 1 ? points[i - 2] : p2;

      final cp1x =
          p1.x + (p2.x - p0.x) * smoothness / 6.0;
      final cp1y =
          p1.fy +
              (p2.fy - p0.fy) *
                  smoothness /
                  6.0;

      final cp2x =
          p2.x - (p3.x - p1.x) * smoothness / 6.0;
      final cp2y =
          p2.fy -
              (p3.fy - p1.fy) *
                  smoothness /
                  6.0;

      path.cubicTo(
        cp1x,
        cp1y,
        cp2x,
        cp2y,
        p2.x,
        p2.fy,
      );
    }
  }

  @override
  void renderComplexPath(Canvas canvas, ChartTransform transform, ILineChartData lineData, bool isDynamicStroke, bool isDynamicPaint) {
    if (!renderDynamicPaint(canvas, transform, lineData, isDynamicStroke, isDynamicPaint)) {
      // NB! Dynamic thickness not supported yet
      renderSimplePath(canvas, transform, lineData);
    }
  }
}
