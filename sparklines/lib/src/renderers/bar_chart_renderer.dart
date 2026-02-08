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

    for (final bar in barData.bars) {

      final barWidth = transformer.transformWidth(barData.width);
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

      // Apply border radius if specified
      RRect? roundedRect;
      if (barData.borderRadius != null) {
        final transformedBorderRadius = transformBorderRadius(
          barData.borderRadius!,
          transformer,
        );
        roundedRect = transformedBorderRadius.resolve(TextDirection.ltr)
            .toRRect(rect);
      }

      // Set paint properties
      if (barData.gradient != null) {
        paint.shader = barData.gradient!.createShader(rect);
      } else {
        paint.color = barData.color ?? Color(0xFF000000);
      }
      paint.style = PaintingStyle.fill;

      // Draw bar
      if (roundedRect != null) {
        canvas.drawRRect(roundedRect, paint);
      } else {
        canvas.drawRect(rect, paint);
      }

      // Draw border if specified
      if (barData.border != null || barData.borderColor != null) {
        paint.style = PaintingStyle.stroke;
        final borderWidth = barData.border?.width ?? 1.0;
        paint.strokeWidth = transformer.transformDimension(borderWidth);
        paint.color = barData.borderColor ?? barData.border?.color ?? Colors.black;

        if (roundedRect != null) {
          canvas.drawRRect(roundedRect, paint);
        } else {
          canvas.drawRect(rect, paint);
        }
      }
    }

  }

}
