import 'package:flutter/material.dart';
import '../data/line_data.dart';
import '../interfaces/chart_transform.dart';
import 'chart_renderer.dart';

class LineChartRenderer extends AChartRenderer<LineData> {

  @override
  void renderData(
    Canvas canvas,
    ChartTransform transform,
    LineData lineData,
  ) {

    if (lineData.points.length < 2) return;

    final paint = Paint();

    final hasAreaFill = lineData.areaGradient != null || lineData.areaColor != null;
    if (hasAreaFill) {
      final areaPath = _buildAreaPathBetweenFyAndY(lineData, transform);
      if (areaPath != null) {

        final tAreaPath = transform.path(areaPath);

        if (lineData.areaGradient != null) {
          paint.shader = lineData.areaGradient!.createShader(tAreaPath.getBounds());
        } else {
          paint.shader = null;
          paint.color = lineData.areaColor!;
        }

        paint.style = PaintingStyle.fill;
        canvas.drawPath(tAreaPath, paint);
      }
    }

    lineData.lineType.renderer.render(canvas, transform, lineData);

    drawDataPoints(canvas, paint, transform, lineData, lineData.points);
  }

  Path? _buildAreaPathBetweenFyAndY(LineData lineData, ChartTransform transform) {

    final points = lineData.points;
    if (points.length < 2) return null;

    final renderer = lineData.lineType.renderer;

    final areaPath = renderer.toPath(lineData.lineType, points);
    renderer.toPath(lineData.lineType, points, useFy: false, reverse: true, path: areaPath);

    areaPath..fillType = lineData.areaFillType ?? PathFillType.evenOdd
      ..close();

    return areaPath;
  }
}
