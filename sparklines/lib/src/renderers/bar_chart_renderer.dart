import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../coordinate_transformer.dart';
import '../chart_data.dart';
import 'base_renderer.dart';

/// Renders bar charts
class BarChartRenderer extends BaseRenderer<BarData> {

  @override
  void renderData(
    Canvas canvas,
    CoordinateTransformer transformer,
    BarData barData,
  ) {

    final paint = Paint();
    final thickness = barData.thickness;

    for (final bar in barData.bars) {

      final barWidth = transformer.transformDimension(thickness.size);
      final barX = transformer.transformX(bar.x) - barWidth / 2;
      final barY = transformer.transformY(bar.dy);
      final baseBarY = transformer.transformY(transformer.minY);

      final barHeight = (baseBarY - barY).abs();
      final rect = Rect.fromLTWH(
        barX,
        math.min(barY, baseBarY),
        barWidth,
        barHeight,
      );

      RRect? roundedRect = this.roundedRect(transformer, barData, rect);

      paint.style = PaintingStyle.fill;
      // Set paint properties from thickness (fill)
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

      // Draw border if specified (IChartBorder)
      final border = barData.border;
      if (border != null) {

        paint.style = PaintingStyle.stroke;
        paint.strokeWidth = transformer.transformDimension(border.size);

        if (thickness.gradient != null) {
          paint.shader = thickness.gradient!.createShader(rect);
        } else {
          paint.shader = null;
          paint.color = thickness.color;
        }

        if (roundedRect != null) {
          canvas.drawRRect(roundedRect, paint);
        } else {
          canvas.drawRect(rect, paint);
        }
      }
    }

  }

}
