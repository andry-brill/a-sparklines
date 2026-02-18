import 'package:flutter/material.dart';
import 'package:sparklines/src/data/data_point.dart';
import 'package:sparklines/src/interfaces.dart';

import '../../data/line_data.dart';
import 'base_line_type_renderer.dart';

/// Renders curved (smooth) line connections between points
class CurvedLineRenderer extends BaseLineTypeRenderer<CurvedLineData> {

  const CurvedLineRenderer();

  @override
  Path toLinePath(CurvedLineData lineType, Path path, List<DataPoint> points, {bool useFy = true, bool reverse = false}) {

    final smoothness = lineType.smoothness;

    if (reverse) {
      for (int i = points.length - 1; i >= 1; i--) {
        final curr = points[i];
        final prev = points[i - 1];
        if (i == points.length - 1) {
          final controlX = prev.x + (curr.x - prev.x) * smoothness;
          path.quadraticBezierTo(controlX, curr.getYorFY(useFy), prev.x, prev.getYorFY(useFy));
        } else if (i == 1) {
          final controlX = curr.x - (curr.x - prev.x) * smoothness;
          path.quadraticBezierTo(controlX, prev.getYorFY(useFy), prev.x, prev.getYorFY(useFy));
        } else {
          final next = points[i + 1];
          final controlX1 = curr.x - (curr.x - next.x) * smoothness;
          final controlX2 = prev.x + (curr.x - prev.x) * smoothness;
          path.cubicTo(controlX1, curr.getYorFY(useFy), controlX2, prev.getYorFY(useFy), prev.x, prev.getYorFY(useFy));
        }
      }
    } else {
      for (int i = 1; i < points.length; i++) {
        final prev = points[i - 1];
        final curr = points[i];

        if (i == 1) {
          final controlX = prev.x + (curr.x - prev.x) * smoothness;
          path.quadraticBezierTo(controlX, prev.getYorFY(useFy), curr.x, curr.getYorFY(useFy));
        } else if (i == points.length - 1) {
          final controlX = curr.x - (curr.x - prev.x) * smoothness;
          path.quadraticBezierTo(controlX, curr.getYorFY(useFy), curr.x, curr.getYorFY(useFy));
        } else {
          final next = points[i + 1];
          final controlX1 = prev.x + (curr.x - prev.x) * smoothness;
          final controlX2 = curr.x - (next.x - curr.x) * smoothness;
          path.cubicTo(controlX1, prev.getYorFY(useFy), controlX2, curr.getYorFY(useFy), curr.x, curr.getYorFY(useFy));
        }
      }
    }

    return path;
  }

  @override
  void renderComplexPath(ChartRenderContext context, LineData lineData, bool isDynamicStroke, bool isDynamicPaint) {
  }
}
