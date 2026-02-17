import 'package:flutter/material.dart';
import 'package:sparklines/src/data/between_line_data.dart';
import 'package:sparklines/src/interfaces.dart';
import 'package:sparklines/src/renderers/chart_renderer.dart';

/// Renders area between two lines
class BetweenLineRenderer extends AChartRenderer<BetweenLineData> {

  @override
  void renderData(
    ChartRenderContext context,
    BetweenLineData betweenData,
  ) {
    final paint = Paint();

    final combinedPath = betweenData.from.lineType.toPath(betweenData.from.points);
    betweenData.to.lineType.toPath(betweenData.to.points, reverse: true, path: combinedPath);
    combinedPath.close();

    final tPath = combinedPath.transform(context.pathTransform.storage);

    if (betweenData.areaGradient != null) {
      paint.shader = betweenData.areaGradient!.createShader(tPath.getBounds());
    } else {
      paint.shader = null;
      paint.color = betweenData.areaColor;
    }

    paint.style = PaintingStyle.fill;

    context.canvas.drawPath(tPath, paint);
  }

}
