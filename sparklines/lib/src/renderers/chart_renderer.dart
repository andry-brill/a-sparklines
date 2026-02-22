import 'package:flutter/material.dart';
import '../data/data_point.dart';
import '../interfaces.dart';

abstract class AChartRenderer<DT extends ISparklinesData> implements IChartRenderer {

  @override
  void render(
    Canvas canvas,
    ChartTransform transform,
    ISparklinesData data,
  ) {
    renderData(canvas, transform, data as DT);
  }

  void renderData(Canvas canvas, ChartTransform transform, DT data);

  RRect? roundedRect(ChartTransform transform, IChartBorder border, Rect rect) {
    if (border.borderRadius == null || border.borderRadius == 0.0) {
      return null;
    }
    final r = transform.scalar(border.borderRadius!);
    return RRect.fromRectXY(rect, r, r);
  }

  void drawDataPoints(
    Canvas canvas,
    Paint paint,
    ChartTransform transform,
    IChartDataPointStyle chart,
    List<DataPoint> points,
  ) {
    for (final point in points) {
      final pointStyle = point.style ?? chart.pointStyle;
      if (pointStyle != null) {
        pointStyle.renderer.render(canvas, transform, paint, pointStyle, point);
      }
    }
  }
}
