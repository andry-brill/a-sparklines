import 'package:flutter/material.dart';
import 'package:sparklines/src/data/data_point.dart';
import 'package:sparklines/src/interfaces.dart';

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

    }
  }
}
