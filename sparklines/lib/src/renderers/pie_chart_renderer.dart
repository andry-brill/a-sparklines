import 'dart:math';
import 'package:flutter/material.dart';
import 'package:sparklines/sparklines.dart';
import 'package:sparklines/src/data/pie_slice_layout.dart';
import 'package:sparklines/src/renderers/chart_renderer.dart';


class PieChartRenderer extends AChartRenderer<PieData> {

  @override
  void renderData(
    ChartRenderContext context,
    PieData pieData,
  ) {

    final cornerRadius = pieData.borderRadius != null
        ? context.toScreenLength(pieData.borderRadius!)
        : 0.0;

    final layouts = computePieLayouts(
      pieData.points,
      pieData.space,
      pieData.thickness.size,
      pieData.thickness.align,
      cornerRadius
    );

    final paint = Paint();

    for (final layout in layouts) {

      Path pie = layout.toPath();
      pie = pie.transform(context.pathTransform.storage);

      paint.style = PaintingStyle.fill;

      final shaderRect = pie.getBounds();
      final thickness = pieData.thickness;
      if (thickness.gradient != null) {
        paint.shader = thickness.gradient!.createShader(shaderRect);
      } else {
        paint.shader = null;
        paint.color = thickness.color;
      }

      context.canvas.drawPath(pie, paint);

      final border = pieData.border;
      if (border != null) {
        final borderSize = context.toScreenLength(border.size);

        final borderLayout = PieSliceLayout(
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

    drawDataPoints(paint, context, pieData, pieData.points);
  }

}
