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

      final centerX = transformer.transformX(bar.x);
      final barWidth = transformer.transformDimension(thickness.size);
      // align 0 => centered; align < 0 => shift left; align > 0 => shift right
      final barX = centerX - barWidth / 2 + barWidth * thickness.align;
      // Bar from (x, y) to (x, fy): y = offset/base, dy = value, fy = y + dy
      final topY = transformer.transformY(bar.fy);
      final baseY = transformer.transformY(bar.y);

      final barHeight = (baseY - topY).abs();
      final rect = Rect.fromLTWH(
        barX,
        math.min(topY, baseY),
        barWidth,
        barHeight,
      );

      RRect? roundedRect = this.roundedRect(transformer, barData, rect);

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

      // Draw border if specified (IChartBorder)
      final border = barData.border;
      if (border != null) {

        final borderSize = transformer.transformDimension(border.size);
        // align 0 => same rect; align > 0 => inflate equally (center unchanged); align < 0 => deflate
        final borderRect = rect.inflate(borderSize * border.align);

        RRect? borderRoundedRect = this.roundedRect(transformer, barData, borderRect);

        paint.style = PaintingStyle.stroke;
        paint.strokeWidth = borderSize;

        if (thickness.gradient != null) {
          paint.shader = thickness.gradient!.createShader(borderRect);
        } else {
          paint.shader = null;
          paint.color = thickness.color;
        }

        if (borderRoundedRect != null) {
          canvas.drawRRect(borderRoundedRect, paint);
        } else {
          canvas.drawRect(borderRect, paint);
        }
      }
    }

  }

}
