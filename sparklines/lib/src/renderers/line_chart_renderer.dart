import 'package:flutter/material.dart';
import 'package:sparklines/src/data/line_data.dart';
import 'package:sparklines/src/data/data_point.dart';
import 'package:sparklines/src/interfaces.dart';
import 'chart_renderer.dart';

class LineChartRenderer extends AChartRenderer<LineData> {
  @override
  void renderData(
    Canvas canvas,
    ChartRenderContext context,
    LineData lineData,
  ) {
    if (lineData.points.length < 2) return;

    final paint = Paint();

    final path = buildPath(lineData, context);

    final hasAreaFill = lineData.areaGradient != null || lineData.areaColor != null;
    if (hasAreaFill) {
      final areaPath = _buildAreaPathBetweenFyAndY(lineData, context);
      if (areaPath != null) {
        if (lineData.areaGradient != null) {
          paint.shader = lineData.areaGradient!.createShader(context.bounds);
        } else {
          paint.shader = null;
          paint.color = lineData.areaColor!;
        }
        paint.style = PaintingStyle.fill;
        canvas.drawPath(areaPath, paint);
      }
    }

    final thickness = lineData.thickness;
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = context.toScreenLength(thickness.size);
    paint.strokeCap = lineData.isStrokeCapRound ? StrokeCap.round : StrokeCap.butt;
    paint.strokeJoin = lineData.isStrokeJoinRound ? StrokeJoin.round : StrokeJoin.miter;

    if (thickness.gradient != null) {
      paint.shader = thickness.gradient!.createShader(context.bounds);
    } else {
      paint.shader = null;
      paint.color = thickness.color;
    }

    canvas.drawPath(path, paint);

    drawDataPoints(canvas, paint, context, lineData, lineData.points);
  }

  Path? _buildAreaPathBetweenFyAndY(LineData lineData, ChartRenderContext context) {
    final points = lineData.points;
    if (points.length < 2) return null;

    final topPath = buildPath(lineData, context);
    final areaPath = Path.from(topPath);

    final last = points.last;
    areaPath.lineTo(last.x, last.y);

    buildPath(lineData, context, yOf: (DataPoint p) => p.y, reverse: true, path: areaPath);

    final first = points.first;
    areaPath.lineTo(first.x, first.fy);
    return areaPath;
  }

  Path buildPath(LineData lineData, ChartRenderContext context, {double Function(DataPoint)? yOf, bool reverse = false, Path? path}) {
    final pathOut = path ?? Path();
    final points = lineData.points;

    if (points.isEmpty) return pathOut;

    double yVal(DataPoint p) => yOf != null ? yOf(p) : p.fy;
    Offset pt(DataPoint p) => Offset(p.x, yVal(p));

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
      _buildStepPathWithY(pathOut, points, stepData.stepJumpAt, yOf ?? (p) => p.fy, reverse);
    } else if (lineData.lineType is CurvedLineType) {
      final curveData = lineData.lineType as CurvedLineType;
      _buildCurvePathWithY(pathOut, points, curveData.smoothness, yOf ?? (p) => p.fy, reverse);
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
    double stepJumpAt,
    double Function(DataPoint) yOf,
    bool reverse,
  ) {
    if (reverse) {
      for (int i = points.length - 1; i >= 1; i--) {
        final curr = points[i];
        final prev = points[i - 1];
        final stepX = prev.x + (curr.x - prev.x) * stepJumpAt;
        path.lineTo(stepX, yOf(curr));
        path.lineTo(stepX, yOf(prev));
        path.lineTo(prev.x, yOf(prev));
      }
    } else {
      for (int i = 1; i < points.length; i++) {
        final prev = points[i - 1];
        final curr = points[i];
        final stepX = prev.x + (curr.x - prev.x) * stepJumpAt;
        path.lineTo(stepX, yOf(prev));
        path.lineTo(stepX, yOf(curr));
        path.lineTo(curr.x, yOf(curr));
      }
    }
  }

  void _buildCurvePathWithY(
    Path path,
    List<DataPoint> points,
    double smoothness,
    double Function(DataPoint) yOf,
    bool reverse,
  ) {
    if (points.length < 2) return;

    Offset pt(DataPoint p) => Offset(p.x, yOf(p));

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

}
