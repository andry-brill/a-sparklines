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

      // Apply border radius if specified (IChartBorder.borderRadius is uniform double)
      RRect? roundedRect;
      if (barData.borderRadius != null) {
        final uniformRadius = BorderRadius.all(
          Radius.circular(barData.borderRadius!),
        );
        final transformedBorderRadius = transformBorderRadius(
          uniformRadius,
          transformer,
        );
        roundedRect = transformedBorderRadius.resolve(TextDirection.ltr)
            .toRRect(rect);
      }

      // Set paint properties from thickness (fill)
      if (thickness.gradient != null) {
        paint.shader = thickness.gradient!.createShader(rect);
      } else {
        paint.color = thickness.color;
      }
      paint.style = PaintingStyle.fill;

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
        final borderWidth = border.size ?? 1.0;
        paint.strokeWidth = transformer.transformDimension(borderWidth);
        paint.color = border.color ?? Colors.black;

        if (roundedRect != null) {
          canvas.drawRRect(roundedRect, paint);
        } else {
          canvas.drawRect(rect, paint);
        }
      }
    }

  }

}
