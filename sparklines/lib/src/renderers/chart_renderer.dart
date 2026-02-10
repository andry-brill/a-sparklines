import 'package:flutter/material.dart';
import '../data/data_point.dart';
import '../interfaces.dart';

abstract class AChartRenderer<DT extends ISparklinesData> implements IChartRenderer {
  @override
  void render(
    ChartRenderContext context,
    ISparklinesData data,
  ) {
    renderData(context, data as DT);
  }

  void renderData(ChartRenderContext context, DT data);

  RRect? roundedRect(ChartRenderContext context, IChartBorder border, Rect rect) {
    if (border.borderRadius == null || border.borderRadius == 0.0) {
      return null;
    }
    final r = context.toScreenLength(border.borderRadius!);
    return RRect.fromRectXY(rect, r, r);
  }

  void drawDataPoints(
    Paint paint,
    ChartRenderContext context,
    IChartDataPointStyle chart,
    List<DataPoint> points,
  ) {
    for (final point in points) {
      final pointStyle = point.style ?? chart.pointStyle;
      if (pointStyle != null) {
        pointStyle.renderer.render(paint, context, pointStyle, point);
      }
    }
  }
}
