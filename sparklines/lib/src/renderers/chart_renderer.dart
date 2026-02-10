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
    if (!data.visible) return;

    canvas.save();

    if (context.crop) {
      canvas.clipRect(context.bounds);
    }

    if (data.rotation != 0.0) {
      final center = context.center;
      canvas.translate(center.dx, center.dy);
      canvas.rotate(data.rotation);
      canvas.translate(-center.dx, -center.dy);
    }

    // NB! Prepare must be done before rendering data
    context.layout.prepare(canvas, context.dimensions);

    // NB! Expecting dx and dy be in "chart" coordinates
    canvas.translate(data.origin.dx, data.origin.dy);

    renderData(canvas, context, data as DT);

    canvas.restore();
  }

  void renderData(Canvas canvas, ChartRenderContext context, DT data);

  RRect? roundedRect(ChartRenderContext context, IChartBorder border, Rect rect) {
    if (border.borderRadius == null || border.borderRadius == 0.0) {
      return null;
    }
    final r = context.toScreenLength(border.borderRadius!);
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
        pointStyle.renderer.render(canvas, paint, context, pointStyle, point);
      }
    }
  }
}
