import 'package:flutter/material.dart';
import '../data/data_point.dart';
import '../interfaces.dart';

abstract class AChartRenderer<DT extends ISparklinesData> implements IChartRenderer {

  @override
  void render(
    Canvas canvas,
    ChartRenderContext context,
    ISparklinesData data,
  ) {
    renderData(canvas, context, data as DT);
  }

  void renderData(Canvas canvas, ChartRenderContext context, DT data);

  RRect? roundedRect(ChartRenderContext context, IChartBorder border, Rect rect) {
    if (border.borderRadius == null || border.borderRadius == 0.0) {
      return null;
    }
    final r = context.transformScalar(border.borderRadius!);
    return RRect.fromRectXY(rect, r, r);
  }

  void drawDataPoints(
    Canvas canvas,
    Paint paint,
    ChartRenderContext context,
    IChartDataPointStyle chart,
    List<DataPoint> points,
  ) {
    for (final point in points) {
      final pointStyle = point.style ?? chart.pointStyle;
      if (pointStyle != null) {
        pointStyle.renderer.render(canvas, context, paint, pointStyle, point);
      }
    }
  }
}
