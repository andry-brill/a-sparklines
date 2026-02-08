import 'package:flutter/material.dart';
import '../coordinate_transformer.dart';
import '../chart_data.dart';
import '../data_point.dart';
import '../interfaces.dart';
import 'base_renderer.dart';

class LineChartRenderer extends BaseRenderer<LineData> {

  @override
  void renderData(
    Canvas canvas,
    CoordinateTransformer transformer,
    LineData lineData,
  ) {

    if (lineData.points.length < 2) return;

    final paint = Paint();

    // Build path based on line type
    final path = buildPath(lineData, transformer);

    // Draw area gradient if specified
    if (lineData.gradientArea != null) {
      final areaPath = Path.from(path);
      areaPath.lineTo(
        transformer.transformX(transformer.maxX),
        transformer.transformY(transformer.minY),
      );
      areaPath.lineTo(
        transformer.transformX(transformer.minX),
        transformer.transformY(transformer.minY),
      );
      areaPath.close();

      paint.shader = lineData.gradientArea!.createShader(
        Rect.fromLTWH(0, 0, transformer.width, transformer.height),
      );
      paint.style = PaintingStyle.fill;
      canvas.drawPath(areaPath, paint);
    }

    // Draw line
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = transformer.transformDimension(lineData.width);
    paint.strokeCap = lineData.isStrokeCapRound
        ? StrokeCap.round
        : StrokeCap.butt;
    paint.strokeJoin = lineData.isStrokeJoinRound
        ? StrokeJoin.round
        : StrokeJoin.miter;

    if (lineData.gradient != null) {
      paint.shader = lineData.gradient!.createShader(
        Rect.fromLTWH(0, 0, transformer.width, transformer.height),
      );
    } else {
      paint.shader = null;
      paint.color = lineData.color ?? Color(0xFF000000);
    }

    canvas.drawPath(path, paint);

    // Draw points if style is specified
    if (lineData.pointStyle != null) {
      _drawPoints(canvas, lineData, transformer, paint);
    }

  }

  Path buildPath(LineData lineData, CoordinateTransformer transformer) {
    final path = Path();
    final points = lineData.points;

    if (points.isEmpty) return path;

    // Transform first point
    final firstPoint = transformer.transformPoint(points[0]);
    path.moveTo(firstPoint.dx, firstPoint.dy);

    if (points.length == 1) return path;

    if (lineData.lineType == null) {
      // Straight lines (non-curved path)
      for (int i = 1; i < points.length; i++) {
        final point = transformer.transformPoint(points[i]);
        path.lineTo(point.dx, point.dy);
      }
    } else if (lineData.lineType is SteppedLineType) {
      final stepData = lineData.lineType as SteppedLineType;
      _buildStepPath(path, points, transformer, stepData.stepJumpAt);
    } else if (lineData.lineType is CurvedLineType) {
      final curveData = lineData.lineType as CurvedLineType;
      _buildCurvePath(path, points, transformer, curveData.smoothness);
    } else {
      // Fallback to straight lines for unknown types
      for (int i = 1; i < points.length; i++) {
        final point = transformer.transformPoint(points[i]);
        path.lineTo(point.dx, point.dy);
      }
    }

    return path;
  }

  void _buildStepPath(
    Path path,
    List<DataPoint> points,
    CoordinateTransformer transformer,
    double stepJumpAt,
  ) {
    for (int i = 1; i < points.length; i++) {
      final prev = points[i - 1];
      final curr = points[i];

      final prevX = transformer.transformX(prev.x);
      final currX = transformer.transformX(curr.x);
      final prevY = transformer.transformY(prev.dy);
      final currY = transformer.transformY(curr.dy);

      final stepX = prevX + (currX - prevX) * stepJumpAt;

      // Horizontal line to step position
      path.lineTo(stepX, prevY);
      // Vertical line to new Y
      path.lineTo(stepX, currY);
      // Horizontal line to current X
      path.lineTo(currX, currY);
    }
  }

  void _buildCurvePath(
    Path path,
    List<DataPoint> points,
    CoordinateTransformer transformer,
    double smoothness,
  ) {
    if (points.length < 2) return;

    for (int i = 1; i < points.length; i++) {
      final prev = points[i - 1];
      final curr = points[i];

      final prevPoint = transformer.transformPoint(prev);
      final currPoint = transformer.transformPoint(curr);

      if (i == 1) {
        // First segment: use current point as control
        final controlX = prevPoint.dx + (currPoint.dx - prevPoint.dx) * smoothness;
        path.quadraticBezierTo(
          controlX,
          prevPoint.dy,
          currPoint.dx,
          currPoint.dy,
        );
      } else if (i == points.length - 1) {
        // Last segment: use previous point as control
        final controlX = currPoint.dx - (currPoint.dx - prevPoint.dx) * smoothness;
        path.quadraticBezierTo(
          controlX,
          currPoint.dy,
          currPoint.dx,
          currPoint.dy,
        );
      } else {
        // Middle segments: use both points for smooth curve
        final next = points[i + 1];
        final nextPoint = transformer.transformPoint(next);

        final controlX1 = prevPoint.dx + (currPoint.dx - prevPoint.dx) * smoothness;
        final controlX2 = currPoint.dx - (nextPoint.dx - currPoint.dx) * smoothness;

        path.cubicTo(
          controlX1,
          prevPoint.dy,
          controlX2,
          currPoint.dy,
          currPoint.dx,
          currPoint.dy,
        );
      }
    }
  }

  void _drawPoints(
    Canvas canvas,
    LineData lineData,
    CoordinateTransformer transformer,
    Paint paint,
  ) {
    if (lineData.pointStyle is! CircleDataPointStyle) return;

    final style = lineData.pointStyle as CircleDataPointStyle;
    paint.style = PaintingStyle.fill;
    paint.color = style.color;

    for (final point in lineData.points) {
      final screenPoint = transformer.transformPoint(point);
      final radius = transformer.transformDimension(style.radius);
      canvas.drawCircle(screenPoint, radius, paint);
    }
  }
}
