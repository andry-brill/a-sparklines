import 'package:flutter/material.dart';
import 'package:sparklines/src/data/data_point.dart';
import 'package:sparklines/src/interfaces.dart';

import '../../data/line_data.dart';

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

    final bool sameStroke = _isSameStrokeSize(lineData.thickness, points);
    final bool samePaint = _isSameStrokePainter(lineData.thickness, points);

    if (sameStroke && samePaint) {
      renderSimplePath(context, lineData);
    } else {
      renderComplexPath(context, lineData, !sameStroke, !samePaint);
    }
  }

  Paint buildStrokePaint(ChartRenderContext context, LineData lineData, [ThicknessOverride? override]) {
    return Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = context.toScreenLength(override?.size ?? lineData.thickness.size)
      ..strokeCap = lineData.lineType.isStrokeCapRound ? StrokeCap.round : StrokeCap.butt
      ..strokeJoin = lineData.lineType.isStrokeJoinRound ? StrokeJoin.round : StrokeJoin.miter;
  }

  Paint buildFillPaint(ChartRenderContext context, LineData lineData) {
    return Paint()
      ..style = PaintingStyle.fill;
  }

  void paintThickness(Paint paint, Rect bounds, ThicknessData thickness, [ThicknessOverride? override]) {

    final gradient = override?.gradient ?? thickness.gradient;

    if (gradient != null) {
      paint.shader = gradient.createShader(bounds);
    } else {
      paint.shader = null;
      paint.color = override?.color ?? thickness.color;
    }
  }

  void renderSimplePath(ChartRenderContext context, LineData lineData) {

    final stroke = lineData.thickness;

    final path = toPath(lineData.lineType, lineData.points);
    final tPath = path.transform(context.pathTransform.storage);

    final paint = buildStrokePaint(context, lineData);
    paintThickness(paint, tPath.getBounds(), stroke);
    context.canvas.drawPath(tPath, paint);
  }

  void renderComplexPath(ChartRenderContext context, LineData lineData, bool isDynamicStroke, bool isDynamicPaint);
}
