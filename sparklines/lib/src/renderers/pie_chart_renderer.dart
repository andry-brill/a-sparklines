import 'dart:math';
import 'package:flutter/material.dart';
import 'package:sparklines/sparklines.dart';
import 'package:sparklines/src/data/pie_slice_data.dart';
import 'package:sparklines/src/renderers/chart_renderer.dart';


class PieChartRenderer extends AChartRenderer<PieData> {

  @override
  void renderData(
    ChartRenderContext context,
    PieData pieData,
  ) {



    final layouts = computePies(
      pieData.points,
      pieData.space,
      pieData.thickness,
      pieData.borderRadius ?? 0.0,
      context
    );

    final paint = Paint();

    for (final layout in layouts) {

      Path pie = layout.toPath();
      pie = pie.transform(context.pathTransform.storage);

      paint.style = PaintingStyle.fill;

      final thickness = pieData.thickness;
      final thicknessGradient = layout.point.thickness?.gradient ?? thickness.gradient;
      if (thicknessGradient != null) {
        paint.shader = thicknessGradient.createShader(pie.getBounds());
      } else {
        paint.shader = null;
        paint.color = layout.point.thickness?.color ?? thickness.color;
      }

      context.canvas.drawPath(pie, paint);

      final border = pieData.border;
      if (border != null) {
        final borderSize = context.toScreenLength(border.size);

        final borderLayout = PieSliceData(
          offset: layout.offset,
          innerRadius: max(0, layout.innerRadius - borderSize * border.align),
          outerRadius: layout.outerRadius + borderSize * border.align,
          startAngle: layout.startAngle,
          endAngle: layout.endAngle,
          point: layout.point,
          cornerRadius: layout.cornerRadius
        );

        Path pieBorderPath = borderLayout.toPath();

        paint.style = PaintingStyle.stroke;
        paint.strokeWidth = borderSize;

        if (border.gradient != null) {
          paint.shader = border.gradient!.createShader(pieBorderPath.getBounds());
        } else {
          paint.shader = null;
          paint.color = border.color;
        }

        context.canvas.drawPath(pieBorderPath, paint);
      }
    }

    // Place each data point at the slice mid-angle on the circle, in Cartesian (x, y).
    var midPoints = pieData.points.map((point) {
      final midAngle = point.y + point.dy / 2;
      final x = point.x * cos(midAngle);
      final y = point.x * sin(midAngle);
      return point.copyWith(x: x, y: y, dy: 0.0);
    }).toList();

    drawDataPoints(paint, context, pieData, midPoints);
  }

}
