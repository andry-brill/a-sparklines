import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:sparklines/src/data/bar_data.dart';
import 'package:sparklines/src/interfaces.dart';
import 'chart_renderer.dart';

/// Renders bar charts
class BarChartRenderer extends AChartRenderer<BarData> {
  @override
  void renderData(
    Canvas canvas,
    ChartRenderContext context,
    BarData barData,
  ) {
    final paint = Paint();
    final thickness = barData.thickness;

    for (final bar in barData.bars) {
      final centerX = bar.x;
      final barWidth = context.toScreenLength(thickness.size);
      final barX = centerX - barWidth / 2 + barWidth * thickness.align;
      final topY = bar.fy;
      final baseY = bar.y;

      final barHeight = (baseY - topY).abs();
      final rect = Rect.fromLTWH(
        barX,
        math.min(topY, baseY),
        barWidth,
        barHeight,
      );

      RRect? roundedRect = this.roundedRect(context, barData, rect);

      paint.style = PaintingStyle.fill;

      if (thickness.gradient != null) {
        paint.shader = thickness.gradient!.createShader(rect);
      } else {
        paint.shader = null;
        paint.color = thickness.color;
      }

      // Draw bar
      if (roundedRect != null) {
        canvas.drawRRect(roundedRect, paint);
      } else {
        canvas.drawRect(rect, paint);
      }

      final border = barData.border;
      if (border != null) {
        final borderSize = context.toScreenLength(border.size);
        final borderRect = rect.inflate(borderSize * border.align);

        RRect? borderRoundedRect = this.roundedRect(context, barData, borderRect);

        paint.style = PaintingStyle.stroke;
        paint.strokeWidth = borderSize;

        if (border.gradient != null) {
          paint.shader = border.gradient!.createShader(borderRect);
        } else {
          paint.shader = null;
          paint.color = border.color;
        }

        if (borderRoundedRect != null) {
          canvas.drawRRect(borderRoundedRect, paint);
        } else {
          canvas.drawRect(borderRect, paint);
        }
      }
    }

    drawDataPoints(canvas, paint, context, barData, barData.bars);

  }

}
