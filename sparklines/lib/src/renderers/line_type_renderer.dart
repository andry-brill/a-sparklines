import 'package:flutter/material.dart';
import 'package:sparklines/src/data/data_point.dart';
import 'package:sparklines/src/interfaces.dart';

import '../data/line_data.dart';

/// Base renderer with shared moveToStart logic
abstract class BaseLineTypeRenderer<LD extends ILineTypeData> implements ILineTypeRenderer {

  const BaseLineTypeRenderer();

  @override
  Path toPath(ILineTypeData lineType, List<DataPoint> points, {bool useFy = true, bool reverse = false, Path? path}) {

    final pathOut = path ?? Path();
    if (points.isEmpty) return pathOut;

    moveToStart(pathOut, points, useFy, reverse);
    if (points.length == 1) return pathOut;

    return toLinePath(lineType as LD, pathOut, points, useFy: useFy, reverse: reverse);
  }

  Path toLinePath(LD lineType, Path path, List<DataPoint> points, {bool useFy = true, bool reverse = false});

  void moveToStart(Path path, List<DataPoint> points, bool useFy, bool reverse) {
    if (!reverse) {
      final first = points[0];
      path.moveTo(first.x, first.getYorFY(useFy));
    } else {
      final last = points.last;
      path.moveTo(last.x, last.getYorFY(useFy));
    }
  }

  bool _isSameStrokeSize(ThicknessData stroke, List<DataPoint> points) {
    final size = stroke.size;
    for (var point in points) {
      final override = point.thickness?.size;
      if (override != null && size != override) return false;
    }
    return true;
  }

  bool _isSameStrokePainter(ThicknessData stroke, List<DataPoint> points) {
    final painter = stroke.gradient ?? stroke.color;
    for (var point in points) {
      final override = point.thickness?.gradient ?? point.thickness?.color;
      if (override != null && painter != override) return false;
    }
    return true;
  }

  @override
  void render(ChartRenderContext context, LineData lineData) {
    final points = lineData.points;
    if (points.length < 2) return;

    final stroke = lineData.thickness;
    if (!_isSameStrokeSize(stroke, points)) {
      // TODO build global stroke path
      return;
    }

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = context.toScreenLength(stroke.size)
      ..strokeCap = lineData.lineType.isStrokeCapRound ? StrokeCap.round : StrokeCap.butt
      ..strokeJoin = lineData.lineType.isStrokeJoinRound ? StrokeJoin.round : StrokeJoin.miter;

    final path = toPath(lineData.lineType, points);
    final tPath = path.transform(context.pathTransform.storage);

    if (_isSameStrokePainter(stroke, points)) {
      if (stroke.gradient != null) {
        paint.shader = stroke.gradient!.createShader(tPath.getBounds());
      } else {
        paint.shader = null;
        paint.color = stroke.color;
      }
      context.canvas.drawPath(tPath, paint);
    } else {
      // TODO build global gradient
    }
  }
}

/// Renders linear (straight line) connections between points
class LinearLineRenderer extends BaseLineTypeRenderer<LinearLineData> {

  const LinearLineRenderer();

  @override
  Path toLinePath(LinearLineData lineType, Path path, List<DataPoint> points, {bool useFy = true, bool reverse = false}) {

    if (reverse) {
      for (int i = points.length - 2; i >= 0; i--) {
        final point = points[i];
        path.lineTo(point.x, point.getYorFY(useFy));
      }
    } else {
      for (int i = 1; i < points.length; i++) {
        final point = points[i];
        path.lineTo(point.x, point.getYorFY(useFy));
      }
    }

    return path;
  }
}

/// Renders curved (smooth) line connections between points
class CurvedLineRenderer extends BaseLineTypeRenderer<CurvedLineData> {

  const CurvedLineRenderer();

  @override
  Path toLinePath(CurvedLineData lineType, Path path, List<DataPoint> points, {bool useFy = true, bool reverse = false}) {

    final smoothness = lineType.smoothness;

    if (reverse) {
      for (int i = points.length - 1; i >= 1; i--) {
        final curr = points[i];
        final prev = points[i - 1];
        if (i == points.length - 1) {
          final controlX = prev.x + (curr.x - prev.x) * smoothness;
          path.quadraticBezierTo(controlX, curr.getYorFY(useFy), prev.x, prev.getYorFY(useFy));
        } else if (i == 1) {
          final controlX = curr.x - (curr.x - prev.x) * smoothness;
          path.quadraticBezierTo(controlX, prev.getYorFY(useFy), prev.x, prev.getYorFY(useFy));
        } else {
          final next = points[i + 1];
          final controlX1 = curr.x - (curr.x - next.x) * smoothness;
          final controlX2 = prev.x + (curr.x - prev.x) * smoothness;
          path.cubicTo(controlX1, curr.getYorFY(useFy), controlX2, prev.getYorFY(useFy), prev.x, prev.getYorFY(useFy));
        }
      }
    } else {
      for (int i = 1; i < points.length; i++) {
        final prev = points[i - 1];
        final curr = points[i];

        if (i == 1) {
          final controlX = prev.x + (curr.x - prev.x) * smoothness;
          path.quadraticBezierTo(controlX, prev.getYorFY(useFy), curr.x, curr.getYorFY(useFy));
        } else if (i == points.length - 1) {
          final controlX = curr.x - (curr.x - prev.x) * smoothness;
          path.quadraticBezierTo(controlX, curr.getYorFY(useFy), curr.x, curr.getYorFY(useFy));
        } else {
          final next = points[i + 1];
          final controlX1 = prev.x + (curr.x - prev.x) * smoothness;
          final controlX2 = curr.x - (next.x - curr.x) * smoothness;
          path.cubicTo(controlX1, prev.getYorFY(useFy), controlX2, curr.getYorFY(useFy), curr.x, curr.getYorFY(useFy));
        }
      }
    }

    return path;
  }
}


class SteppedLineRenderer extends BaseLineTypeRenderer<SteppedLineData> {

  const SteppedLineRenderer();

  @override
  Path toLinePath(SteppedLineData lineType, Path path, List<DataPoint> points, {bool useFy = true, bool reverse = false}) {

    if (reverse) {
      for (int i = points.length - 1; i >= 1; i--) {
        final curr = points[i];
        final prev = points[i - 1];
        final stepX = prev.x + (curr.x - prev.x) * lineType.stepJumpAt;
        path.lineTo(stepX, curr.getYorFY(useFy));
        path.lineTo(stepX, prev.getYorFY(useFy));
        path.lineTo(prev.x, prev.getYorFY(useFy));
      }
    } else {
      for (int i = 1; i < points.length; i++) {
        final prev = points[i - 1];
        final curr = points[i];
        final stepX = prev.x + (curr.x - prev.x) * lineType.stepJumpAt;
        path.lineTo(stepX, prev.getYorFY(useFy));
        path.lineTo(stepX, curr.getYorFY(useFy));
        path.lineTo(curr.x, curr.getYorFY(useFy));
      }
    }

    return path;
  }


}
