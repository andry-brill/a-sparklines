import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:sparklines/src/data/pie_data.dart';
import 'package:sparklines/src/renderers/chart_renderer.dart';
import 'package:sparklines/src/layout/coordinate_transformer.dart';
import 'package:sparklines/src/interfaces.dart';

/// Renders pie charts
class PieChartRenderer extends AChartRenderer<PieData> {

  @override
  void renderData(
    Canvas canvas,
    CoordinateTransformer transformer,
    PieData pieData,
  ) {

    final paint = Paint();

    // Calculate total arc length
    final totalArc = pieData.points.fold<double>(
      0.0,
      (sum, pie) => sum + pie.dy,
    );

    if (totalArc <= 0) return;

    // Calculate center and radius
    final center = transformer.center;
    final radius = math.min(center.dx, center.dy);

    // Render each pie segment
    double startAngle = pieData.points.isNotEmpty ? pieData.points[0].x : 0.0;
    final spaceAngle = pieData.space * math.pi / 180.0; // Convert to radians

    for (int i = 0; i < pieData.points.length; i++) {
      final pie = pieData.points[i];
      final sweepAngle = (pie.dy / totalArc) * 2 * math.pi - spaceAngle;

      if (sweepAngle <= 0) continue;

      final endAngle = startAngle + sweepAngle;

      if (pieData.thickness.size == double.infinity) {
        // Full sector (filled pie)
        _drawFilledSector(
          canvas,
          paint,
          radius,
          startAngle,
          endAngle,
          pieData,
          transformer,
        );
      } else {
        // Arc with stroke
        _drawStrokedArc(
          canvas,
          paint,
          radius,
          startAngle,
          endAngle,
          pieData,
          transformer,
        );
      }

      startAngle = endAngle + spaceAngle;
    }

  }

  void _drawFilledSector(
    Canvas canvas,
    Paint paint,
    double radius,
    double startAngle,
    double endAngle,
    PieData pieData,
    CoordinateTransformer transformer,
  ) {

    double? transformedBorderRadius;
    if (pieData.borderRadius != null) {
      transformedBorderRadius = transformer.transformDimension(pieData.borderRadius!);
    }

    final hasRoundedCorners = transformedBorderRadius != null &&
        (transformedBorderRadius > 0);

    final path = hasRoundedCorners
        ? _buildRoundedSectorPath(
            radius,
            startAngle,
            endAngle,
            transformedBorderRadius,
          )
        : () {
            final p = Path();
            p.moveTo(0, 0);
            p.arcTo(
              Rect.fromCircle(center: Offset.zero, radius: radius),
              startAngle,
              endAngle - startAngle,
              false,
            );
            p.close();
            return p;
          }();

    final thickness = pieData.thickness;
    if (thickness.gradient != null) {
      paint.shader = thickness.gradient!.createShader(
        Rect.fromCircle(center: Offset.zero, radius: radius),
      );
    } else {
      paint.color = thickness.color;
    }
    paint.style = PaintingStyle.fill;
    canvas.drawPath(path, paint);

    final border = pieData.border;
    if (border != null) {
      paint.style = PaintingStyle.stroke;
      paint.strokeWidth = transformer.transformDimension(border.size);
      paint.color = border.color;
      canvas.drawPath(path, paint);
    }
  }

  void _drawStrokedArc(
    Canvas canvas,
    Paint paint,
    double radius,
    double startAngle,
    double endAngle,
    PieData pieData,
    CoordinateTransformer transformer,
  ) {
    final thickness = pieData.thickness;
    final strokeWidth = transformer.transformDimension(thickness.size);
    double innerRadius = radius;
    double outerRadius = radius;

    final align = thickness.align;
    if (align <= ThicknessData.alignInside + 0.5) {
      innerRadius = radius - strokeWidth;
      outerRadius = radius;
    } else if (align >= ThicknessData.alignOutside - 0.5) {
      innerRadius = radius;
      outerRadius = radius + strokeWidth;
    } else {
      innerRadius = radius - strokeWidth / 2;
      outerRadius = radius + strokeWidth / 2;
    }

    double? transformedBorderRadius;
    if (pieData.borderRadius != null) {
      transformedBorderRadius = transformer.transformDimension(pieData.borderRadius!);
    }

    final hasRoundedCorners = transformedBorderRadius != null &&
        (transformedBorderRadius > 0);

    final path = hasRoundedCorners
        ? _buildRoundedArcPath(
            innerRadius,
            outerRadius,
            startAngle,
            endAngle,
          )
        : () {
            final p = Path();
            p.addArc(
              Rect.fromCircle(center: Offset.zero, radius: outerRadius),
              startAngle,
              endAngle - startAngle,
            );
            p.arcTo(
              Rect.fromCircle(center: Offset.zero, radius: innerRadius),
              endAngle,
              startAngle - endAngle,
              false,
            );
            p.close();
            return p;
          }();

    // Fill (IChartThickness)
    if (thickness.gradient != null) {
      paint.shader = thickness.gradient!.createShader(
        Rect.fromCircle(center: Offset.zero, radius: outerRadius),
      );
    } else {
      paint.color = thickness.color;
    }
    paint.style = PaintingStyle.fill;
    canvas.drawPath(path, paint);

    // Border (IChartBorder)
    final border = pieData.border;
    if (border != null) {
      paint.style = PaintingStyle.stroke;
      paint.strokeWidth = transformer.transformDimension(border.size);
      paint.color = border.color;
      canvas.drawPath(path, paint);
    }
  }

  Path _buildRoundedSectorPath(
    double radius,
    double startAngle,
    double endAngle,
    double cornerRadius,
  ) {
    final path = Path();
    final sweepAngle = endAngle - startAngle;

    // Calculate corner positions
    final startX = math.cos(startAngle) * radius;
    final startY = math.sin(startAngle) * radius;

    // Start from center
    path.moveTo(0, 0);

    // Line to start of arc with rounded corner
    final cornerStartX = math.cos(startAngle) * (radius - cornerRadius);
    final cornerStartY = math.sin(startAngle) * (radius - cornerRadius);
    path.lineTo(cornerStartX, cornerStartY);

    // Rounded corner at start
    double cornerCenterX = math.cos(startAngle) * radius;
    double cornerCenterY = math.sin(startAngle) * radius;
    path.quadraticBezierTo(
      cornerCenterX,
      cornerCenterY,
      startX,
      startY,
    );


    // Arc
    path.arcTo(
      Rect.fromCircle(center: Offset.zero, radius: radius),
      startAngle,
      sweepAngle,
      false,
    );

    // Rounded corner at end
    final cornerEndX = math.cos(endAngle) * (radius - cornerRadius);
    final cornerEndY = math.sin(endAngle) * (radius - cornerRadius);
    cornerCenterX = math.cos(endAngle) * radius;
    cornerCenterY = math.sin(endAngle) * radius;

    path.quadraticBezierTo(
      cornerCenterX,
      cornerCenterY,
      cornerEndX,
      cornerEndY,
    );

    // Close path back to center
    path.close();

    return path;
  }

  Path _buildRoundedArcPath(
    double innerRadius,
    double outerRadius,
    double startAngle,
    double endAngle,
  ) {
    final path = Path();
    final sweepAngle = endAngle - startAngle;

    // Outer arc
    final outerStartX = math.cos(startAngle) * outerRadius;
    final outerStartY = math.sin(startAngle) * outerRadius;

    path.moveTo(outerStartX, outerStartY);
    path.arcTo(
      Rect.fromCircle(center: Offset.zero, radius: outerRadius),
      startAngle,
      sweepAngle,
      false,
    );

    // Inner arc (reversed)

    path.arcTo(
      Rect.fromCircle(center: Offset.zero, radius: innerRadius),
      endAngle,
      -sweepAngle,
      false,
    );

    path.close();

    return path;
  }
}
