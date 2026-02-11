import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:sparklines/src/data/bar_data.dart';
import 'package:sparklines/src/interfaces.dart';
import 'chart_renderer.dart';

/// Renders bar charts.
/// Bar axis (x, y)–(x, fy) is transformed to screen space; thickness is applied
/// in screen space and drawn with [Canvas.drawRect]/[Canvas.drawRRect] so it stays uniform.
class BarChartRenderer extends AChartRenderer<BarData> {

  @override
  void renderData(
    ChartRenderContext context,
    BarData barData,
  ) {

    final paint = Paint();

    final thickness = barData.thickness;
    final barWidth = context.toScreenLength(thickness.size);
    final align = thickness.align;
    final half = barWidth / 2;
    final a = half * (1 + align);
    final b = half * (1 - align);

    for (final bar in barData.bars) {

      // Bar axis in data space: (x, y) -> (x, fy); transform to screen
      final p0 = context.transformXY(bar.x, bar.y);
      final p1 = context.transformXY(bar.x, bar.fy);

      // NB! Expecting to always have same x or y coordinates, so we can use usual rect
      final rect = _screenRectFromAxis(p0, p1, barWidth, a, b);
      RRect? roundedRect = this.roundedRect(context, barData, rect);

      paint.style = PaintingStyle.fill;

      final shaderRect = rect;
      if (thickness.gradient != null) {
        paint.shader = thickness.gradient!.createShader(shaderRect);
      } else {
        paint.shader = null;
        paint.color = thickness.color;
      }

      if (roundedRect != null) {
        context.canvas.drawRRect(roundedRect, paint);
      } else {
        context.canvas.drawRect(rect, paint);
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
          context.canvas.drawRRect(borderRoundedRect, paint);
        } else {
          context.canvas.drawRect(borderRect, paint);
        }
      }
    }

    drawDataPoints(paint, context, barData, barData.bars);
  }

  /// Builds an axis-aligned [Rect] in screen space from the bar axis segment
  /// with uniform thickness (offsets [a] and [b]). Returns bounds for shaders/roundedRect.
  static Rect _screenRectFromAxis(Offset p0, Offset p1, double barWidth, double a, double b) {
    final dx = (p1.dx - p0.dx).abs();
    final dy = (p1.dy - p0.dy).abs();

    if (dx <= 1e-10) {
      final left = p0.dx - b;
      final right = p0.dx + a;
      final top = math.min(p0.dy, p1.dy);
      final bottom = math.max(p0.dy, p1.dy);
      return Rect.fromLTRB(left, top, right, bottom);
    }

    if (dy <= 1e-10) {
      final left = math.min(p0.dx, p1.dx);
      final right = math.max(p0.dx, p1.dx);
      final top = p0.dy - b;
      final bottom = p0.dy + a;
      return Rect.fromLTRB(left, top, right, bottom);
    }

    final dir = Offset(p1.dx - p0.dx, p1.dy - p0.dy);
    final len = math.sqrt(dir.dx * dir.dx + dir.dy * dir.dy);
    final perp = Offset(-dir.dy / len, dir.dx / len);
    final c0 = p0 + perp * a;
    final c1 = p0 - perp * b;
    final c2 = p1 - perp * b;
    final c3 = p1 + perp * a;
    final minX = math.min(math.min(c0.dx, c1.dx), math.min(c2.dx, c3.dx));
    final maxX = math.max(math.max(c0.dx, c1.dx), math.max(c2.dx, c3.dx));
    final minY = math.min(math.min(c0.dy, c1.dy), math.min(c2.dy, c3.dy));
    final maxY = math.max(math.max(c0.dy, c1.dy), math.max(c2.dy, c3.dy));
    return Rect.fromLTRB(minX, minY, maxX, maxY);
  }

}
