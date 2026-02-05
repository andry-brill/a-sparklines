import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../coordinate_transformer.dart';
import '../chart_data.dart';
import '../data_point.dart';
import '../interfaces.dart';
import 'base_renderer.dart';

/// Renders bar charts
class BarChartRenderer extends BaseRenderer {
  @override
  void render(
    Canvas canvas,
    CoordinateTransformer transformer,
    ISparklinesData data,
  ) {
    if (data is! BarData || !data.visible) return;

    final barData = data;
    final paint = Paint();

    // Apply origin offset
    canvas.save();
    canvas.translate(barData.origin.dx, barData.origin.dy);

    // Apply rotation
    if (barData.rotation != 0.0) {
      final center = Offset(transformer.width / 2, transformer.height / 2);
      canvas.translate(center.dx, center.dy);
      canvas.rotate(barData.rotation);
      canvas.translate(-center.dx, -center.dy);
    }

    // Clip if crop is enabled
    if (transformer.crop) {
      canvas.clipRect(
        Rect.fromLTWH(0, 0, transformer.width, transformer.height),
      );
    }

    // Group bars by X for stacking
    final Map<double, List<DataPoint>> groupedBars = {};
    for (final bar in barData.bars) {
      groupedBars.putIfAbsent(bar.x, () => []).add(bar);
    }

    // Render bars
    for (final entry in groupedBars.entries) {
      final x = entry.key;
      final bars = entry.value;

      double baseY = 0.0;
      for (final bar in bars) {
        final barWidth = transformer.transformWidth(barData.width);
        final barX = transformer.transformX(x) - barWidth / 2;
        final barY = transformer.transformY(bar.y);
        final baseBarY = barData.stacked
            ? transformer.transformY(baseY)
            : transformer.transformY(transformer.minY);

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
          roundedRect = barData.borderRadius!.resolve(TextDirection.ltr)
              .toRRect(rect);
        }

        // Set paint properties
        if (barData.gradient != null) {
          paint.shader = barData.gradient!.createShader(rect);
        } else {
          paint.color = barData.color ?? Colors.blue;
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
          paint.strokeWidth = barData.border?.width ?? 1.0;
          paint.color = barData.borderColor ?? barData.border?.color ?? Colors.black;

          if (roundedRect != null) {
            canvas.drawRRect(roundedRect, paint);
          } else {
            canvas.drawRect(rect, paint);
          }
        }

        if (barData.stacked) {
          baseY += bar.y;
        }
      }
    }

    canvas.restore();
  }
}
