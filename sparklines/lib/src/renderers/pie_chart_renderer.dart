import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:sparklines/src/renderers/base_renderer.dart';
import '../coordinate_transformer.dart';
import '../chart_data.dart';
import '../stroke_align.dart';

/// Renders pie charts
class PieChartRenderer extends BaseRenderer<PieData> {

  @override
  void renderData(
    Canvas canvas,
    CoordinateTransformer transformer,
    PieData pieData,
  ) {

    final paint = Paint();

    // Calculate total arc length
    final totalArc = pieData.pies.fold<double>(
      0.0,
      (sum, pie) => sum + pie.y,
    );

    if (totalArc <= 0) return;

    // Calculate center and radius
    final centerX = transformer.width / 2;
    final centerY = transformer.height / 2;
    final radius = math.min(centerX, centerY) - 10;

    // Render each pie segment
    double startAngle = pieData.pies.isNotEmpty ? pieData.pies[0].x : 0.0;
    final spaceAngle = pieData.space * math.pi / 180.0; // Convert to radians

    for (int i = 0; i < pieData.pies.length; i++) {
      final pie = pieData.pies[i];
      final sweepAngle = (pie.y / totalArc) * 2 * math.pi - spaceAngle;

      if (sweepAngle <= 0) continue;

      final endAngle = startAngle + sweepAngle;

      if (pieData.stroke == double.infinity) {
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
    BorderRadius? transformedBorderRadius;
    if (pieData.borderRadius != null) {
      transformedBorderRadius = transformBorderRadius(
        pieData.borderRadius!,
        transformer,
      );
    }

    final hasRoundedCorners = transformedBorderRadius != null &&
        (transformedBorderRadius.topLeft.x > 0 ||
            transformedBorderRadius.topLeft.y > 0 ||
            transformedBorderRadius.topRight.x > 0 ||
            transformedBorderRadius.topRight.y > 0);

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

    // Fill
    if (pieData.gradient != null) {
      paint.shader = pieData.gradient!.createShader(
        Rect.fromCircle(center: Offset.zero, radius: radius),
      );
    } else {
      paint.color = pieData.color ?? Colors.blue;
    }
    paint.style = PaintingStyle.fill;
    canvas.drawPath(path, paint);

    // Border
    if (pieData.border != null || pieData.borderColor != null) {
      paint.style = PaintingStyle.stroke;
      final borderWidth = pieData.border?.width ?? 1.0;
      paint.strokeWidth = transformer.transformDimension(borderWidth);
      paint.color = pieData.borderColor ?? pieData.border?.color ?? Colors.black;
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
    final strokeWidth = transformer.transformDimension(pieData.stroke);
    double innerRadius = radius;
    double outerRadius = radius;

    switch (pieData.strokeAlign) {
      case StrokeAlign.inside:
        innerRadius = radius - strokeWidth;
        outerRadius = radius;
        break;
      case StrokeAlign.outside:
        innerRadius = radius;
        outerRadius = radius + strokeWidth;
        break;
      case StrokeAlign.center:
        innerRadius = radius - strokeWidth / 2;
        outerRadius = radius + strokeWidth / 2;
        break;
    }

    BorderRadius? transformedBorderRadius;
    if (pieData.borderRadius != null) {
      transformedBorderRadius = transformBorderRadius(
        pieData.borderRadius!,
        transformer,
      );
    }

    final hasRoundedCorners = transformedBorderRadius != null &&
        (transformedBorderRadius.topLeft.x > 0 ||
            transformedBorderRadius.topLeft.y > 0 ||
            transformedBorderRadius.topRight.x > 0 ||
            transformedBorderRadius.topRight.y > 0);

    final path = hasRoundedCorners
        ? _buildRoundedArcPath(
            innerRadius,
            outerRadius,
            startAngle,
            endAngle,
            transformedBorderRadius,
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

    // Fill
    if (pieData.gradient != null) {
      paint.shader = pieData.gradient!.createShader(
        Rect.fromCircle(center: Offset.zero, radius: outerRadius),
      );
    } else {
      paint.color = pieData.color ?? Colors.blue;
    }
    paint.style = PaintingStyle.fill;
    canvas.drawPath(path, paint);

    // Border
    if (pieData.border != null || pieData.borderColor != null) {
      paint.style = PaintingStyle.stroke;
      final borderWidth = pieData.border?.width ?? 1.0;
      paint.strokeWidth = transformer.transformDimension(borderWidth);
      paint.color = pieData.borderColor ?? pieData.border?.color ?? Colors.black;
      canvas.drawPath(path, paint);
    }
  }

  Path _buildRoundedSectorPath(
    double radius,
    double startAngle,
    double endAngle,
    BorderRadius borderRadius,
  ) {
    final path = Path();
    final sweepAngle = endAngle - startAngle;

    // Calculate corner positions
    final startX = math.cos(startAngle) * radius;
    final startY = math.sin(startAngle) * radius;

    // Start from center
    path.moveTo(0, 0);

    // Line to start of arc with rounded corner
    if (borderRadius.topLeft.x > 0 || borderRadius.topLeft.y > 0) {
      final cornerRadius = math.min(
        borderRadius.topLeft.x,
        borderRadius.topLeft.y,
      );
      final cornerStartX = math.cos(startAngle) * (radius - cornerRadius);
      final cornerStartY = math.sin(startAngle) * (radius - cornerRadius);
      path.lineTo(cornerStartX, cornerStartY);

      // Rounded corner at start
      final cornerCenterX = math.cos(startAngle) * radius;
      final cornerCenterY = math.sin(startAngle) * radius;
      path.quadraticBezierTo(
        cornerCenterX,
        cornerCenterY,
        startX,
        startY,
      );
    } else {
      path.lineTo(startX, startY);
    }

    // Arc
    path.arcTo(
      Rect.fromCircle(center: Offset.zero, radius: radius),
      startAngle,
      sweepAngle,
      false,
    );

    // Rounded corner at end
    if (borderRadius.topRight.x > 0 || borderRadius.topRight.y > 0) {
      final cornerRadius = math.min(
        borderRadius.topRight.x,
        borderRadius.topRight.y,
      );
      final cornerEndX = math.cos(endAngle) * (radius - cornerRadius);
      final cornerEndY = math.sin(endAngle) * (radius - cornerRadius);
      final cornerCenterX = math.cos(endAngle) * radius;
      final cornerCenterY = math.sin(endAngle) * radius;

      path.quadraticBezierTo(
        cornerCenterX,
        cornerCenterY,
        cornerEndX,
        cornerEndY,
      );
    }

    // Close path back to center
    path.close();

    return path;
  }

  Path _buildRoundedArcPath(
    double innerRadius,
    double outerRadius,
    double startAngle,
    double endAngle,
    BorderRadius borderRadius,
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
