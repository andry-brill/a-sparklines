import 'package:flutter/material.dart';
import 'package:sparklines/src/data/line_data.dart';
import 'package:sparklines/src/coordinate_transformer.dart';
import 'package:sparklines/src/data/data_point.dart';
import 'package:sparklines/src/interfaces.dart';
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

    // Build path based on line type (line at fy)
    final path = buildPath(lineData, transformer);

    // Draw area fill between line (fy) and baseline (y) when specified
    final hasAreaFill = lineData.areaGradient != null || lineData.areaColor != null;
    if (hasAreaFill) {
      final areaPath = _buildAreaPathBetweenFyAndY(lineData, transformer);
      if (areaPath != null) {
        if (lineData.areaGradient != null) {
          paint.shader = lineData.areaGradient!.createShader(transformer.bounds);
        } else {
          paint.shader = null;
          paint.color = lineData.areaColor!;
        }
        paint.style = PaintingStyle.fill;
        canvas.drawPath(areaPath, paint);
      }
    }

    // Draw line (stroke from IChartThickness)
    final thickness = lineData.thickness;
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = transformer.transformDimension(thickness.size);
    paint.strokeCap = lineData.isStrokeCapRound
        ? StrokeCap.round
        : StrokeCap.butt;
    paint.strokeJoin = lineData.isStrokeJoinRound
        ? StrokeJoin.round
        : StrokeJoin.miter;

    if (thickness.gradient != null) {
      paint.shader = thickness.gradient!.createShader(transformer.bounds);
    } else {
      paint.shader = null;
      paint.color = thickness.color;
    }

    canvas.drawPath(path, paint);

    // Draw points if style is specified
    if (lineData.pointStyle != null) {
      _drawPoints(canvas, lineData, transformer, paint);
    }

  }

  /// Builds area path between line at [points].fy and baseline at [points].y (like between two lines).
  Path? _buildAreaPathBetweenFyAndY(LineData lineData, CoordinateTransformer transformer) {
    final points = lineData.points;
    if (points.length < 2) return null;

    // Top edge: path along fy (first to last)
    final topPath = buildPath(lineData, transformer);
    final areaPath = Path.from(topPath);

    final lastX = transformer.transformX(points.last.x);
    final lastY = transformer.transformY(points.last.y);

    // Down to baseline at last point
    areaPath.lineTo(lastX, lastY);

    // Bottom edge: path along y from last to first (reverse)
    buildPath(lineData, transformer, yOf: (DataPoint p) => p.y, reverse: true, path: areaPath);

    // Close back to first top point (x0, fy0)
    areaPath.lineTo(transformer.transformX(points.first.x), transformer.transformY(points.first.fy));
    return areaPath;
  }

  Path buildPath(LineData lineData, CoordinateTransformer transformer, {double Function(DataPoint)? yOf, bool reverse = false, Path? path}) {
    final pathOut = path ?? Path();
    final points = lineData.points;

    if (points.isEmpty) return pathOut;

    double screenY(DataPoint p) => transformer.transformY(yOf != null ? yOf(p) : p.fy);
    Offset pt(DataPoint p) => Offset(transformer.transformX(p.x), screenY(p));

    if (!reverse) {
      final first = pt(points[0]);
      pathOut.moveTo(first.dx, first.dy);
      if (points.length == 1) return pathOut;
    } else {
      final last = pt(points.last);
      pathOut.moveTo(last.dx, last.dy);
      if (points.length == 1) return pathOut;
    }

    if (lineData.lineType == null) {
      if (reverse) {
        for (int i = points.length - 2; i >= 0; i--) {
          final point = pt(points[i]);
          pathOut.lineTo(point.dx, point.dy);
        }
      } else {
        for (int i = 1; i < points.length; i++) {
          final point = pt(points[i]);
          pathOut.lineTo(point.dx, point.dy);
        }
      }
    } else if (lineData.lineType is SteppedLineType) {
      final stepData = lineData.lineType as SteppedLineType;
      _buildStepPathWithY(pathOut, points, transformer, stepData.stepJumpAt, yOf ?? (p) => p.fy, reverse);
    } else if (lineData.lineType is CurvedLineType) {
      final curveData = lineData.lineType as CurvedLineType;
      _buildCurvePathWithY(pathOut, points, transformer, curveData.smoothness, yOf ?? (p) => p.fy, reverse);
    } else {
      if (reverse) {
        for (int i = points.length - 2; i >= 0; i--) {
          final point = pt(points[i]);
          pathOut.lineTo(point.dx, point.dy);
        }
      } else {
        for (int i = 1; i < points.length; i++) {
          final point = pt(points[i]);
          pathOut.lineTo(point.dx, point.dy);
        }
      }
    }

    return pathOut;
  }

  void _buildStepPathWithY(
    Path path,
    List<DataPoint> points,
    CoordinateTransformer transformer,
    double stepJumpAt,
    double Function(DataPoint) yOf,
    bool reverse,
  ) {
    if (reverse) {
      for (int i = points.length - 1; i >= 1; i--) {
        final curr = points[i];
        final prev = points[i - 1];
        final currX = transformer.transformX(curr.x);
        final prevX = transformer.transformX(prev.x);
        final currY = transformer.transformY(yOf(curr));
        final prevY = transformer.transformY(yOf(prev));
        final stepX = prevX + (currX - prevX) * stepJumpAt;
        path.lineTo(stepX, currY);
        path.lineTo(stepX, prevY);
        path.lineTo(prevX, prevY);
      }
    } else {
      for (int i = 1; i < points.length; i++) {
        final prev = points[i - 1];
        final curr = points[i];
        final prevX = transformer.transformX(prev.x);
        final currX = transformer.transformX(curr.x);
        final prevY = transformer.transformY(yOf(prev));
        final currY = transformer.transformY(yOf(curr));
        final stepX = prevX + (currX - prevX) * stepJumpAt;
        path.lineTo(stepX, prevY);
        path.lineTo(stepX, currY);
        path.lineTo(currX, currY);
      }
    }
  }

  void _buildCurvePathWithY(
    Path path,
    List<DataPoint> points,
    CoordinateTransformer transformer,
    double smoothness,
    double Function(DataPoint) yOf,
    bool reverse,
  ) {
    if (points.length < 2) return;

    Offset pt(DataPoint p) => Offset(transformer.transformX(p.x), transformer.transformY(yOf(p)));

    if (reverse) {
      for (int i = points.length - 1; i >= 1; i--) {
        final curr = points[i];
        final prev = points[i - 1];
        final currPoint = pt(curr);
        final prevPoint = pt(prev);
        if (i == points.length - 1) {
          final controlX = prevPoint.dx + (currPoint.dx - prevPoint.dx) * smoothness;
          path.quadraticBezierTo(controlX, currPoint.dy, prevPoint.dx, prevPoint.dy);
        } else if (i == 1) {
          final controlX = currPoint.dx - (currPoint.dx - prevPoint.dx) * smoothness;
          path.quadraticBezierTo(controlX, prevPoint.dy, prevPoint.dx, prevPoint.dy);
        } else {
          final next = points[i + 1];
          final nextPoint = pt(next);
          final controlX1 = currPoint.dx - (currPoint.dx - nextPoint.dx) * smoothness;
          final controlX2 = prevPoint.dx + (currPoint.dx - prevPoint.dx) * smoothness;
          path.cubicTo(controlX1, currPoint.dy, controlX2, prevPoint.dy, prevPoint.dx, prevPoint.dy);
        }
      }
    } else {
      for (int i = 1; i < points.length; i++) {
        final prev = points[i - 1];
        final curr = points[i];
        final prevPoint = pt(prev);
        final currPoint = pt(curr);

        if (i == 1) {
          final controlX = prevPoint.dx + (currPoint.dx - prevPoint.dx) * smoothness;
          path.quadraticBezierTo(controlX, prevPoint.dy, currPoint.dx, currPoint.dy);
        } else if (i == points.length - 1) {
          final controlX = currPoint.dx - (currPoint.dx - prevPoint.dx) * smoothness;
          path.quadraticBezierTo(controlX, currPoint.dy, currPoint.dx, currPoint.dy);
        } else {
          final next = points[i + 1];
          final nextPoint = pt(next);
          final controlX1 = prevPoint.dx + (currPoint.dx - prevPoint.dx) * smoothness;
          final controlX2 = currPoint.dx - (nextPoint.dx - currPoint.dx) * smoothness;
          path.cubicTo(controlX1, prevPoint.dy, controlX2, currPoint.dy, currPoint.dx, currPoint.dy);
        }
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
