import 'package:flutter/material.dart';
import 'package:sparklines/src/data/line_data.dart';
import 'package:sparklines/src/interfaces.dart';
import 'chart_renderer.dart';

class LineChartRenderer extends AChartRenderer<LineData> {

  @override
  void renderData(
    ChartRenderContext context,
    LineData lineData,
  ) {

    if (lineData.points.length < 2) return;

    final paint = Paint();

    final hasAreaFill = lineData.areaGradient != null || lineData.areaColor != null;
    if (hasAreaFill) {
      final areaPath = _buildAreaPathBetweenFyAndY(lineData, context);
      if (areaPath != null) {
        if (lineData.areaGradient != null) {
          paint.shader = lineData.areaGradient!.createShader(context.bounds);
        } else {
          paint.shader = null;
          paint.color = lineData.areaColor!;
        }
        paint.style = PaintingStyle.fill;
        context.drawPath(areaPath, paint);
      }
    }

    lineData.lineType.renderer.render(context, lineData);

    drawDataPoints(paint, context, lineData, lineData.points);
  }

  Path? _buildAreaPathBetweenFyAndY(LineData lineData, ChartRenderContext context) {
    final points = lineData.points;
    if (points.length < 2) return null;

    final renderer = lineData.lineType.renderer;
    final topPath = renderer.toPath(lineData.lineType, points);
    final areaPath = Path.from(topPath);

    final last = points.last;
    areaPath.lineTo(last.x, last.y);

    renderer.toPath(lineData.lineType, points, useFy: false, reverse: true, path: areaPath);

    final first = points.first;
    areaPath.lineTo(first.x, first.fy);
    return areaPath;
  }
}
