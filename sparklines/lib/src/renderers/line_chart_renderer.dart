import 'package:flutter/material.dart';
import 'package:sparklines/src/data/line_data.dart';
import 'package:sparklines/src/data/data_point.dart';
import 'package:sparklines/src/interfaces.dart';
import 'chart_renderer.dart';

class LineChartRenderer extends AChartRenderer<LineData> {

  @override
  void renderData(
    ChartRenderContext context,
    LineData lineData,
  ) {

    if (lineData.points.length < 2) return;

    final paint = Paint();

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
        context.drawPath(areaPath, paint);
      }
    }

    final stroke = lineData.thickness;

    if (isSameStrokeSize(stroke, lineData.points)) {

      paint.style = PaintingStyle.stroke;
      paint.strokeWidth = context.toScreenLength(stroke.size);
      paint.strokeCap = lineData.lineType.isStrokeCapRound ? StrokeCap.round : StrokeCap.butt;
      paint.strokeJoin = lineData.lineType.isStrokeJoinRound ? StrokeJoin.round : StrokeJoin.miter;

      final path = lineData.lineType.toPath(lineData.points);
      final tPath = path.transform(context.pathTransform.storage);

      if (isSameStrokePainter(stroke, lineData.points)) {
        if (stroke.gradient != null) {
          paint.shader = stroke.gradient!.createShader(tPath.getBounds());
        } else {
          paint.shader = null;
          paint.color = stroke.color;
        }
      } else {
        // TODO build global gradient
      }

      context.canvas.drawPath(tPath, paint);

    } else {
      // TODO build global gradient
      // TODO build global stroke path
    }

    drawDataPoints(paint, context, lineData, lineData.points);
  }

  bool isSameStrokeSize(ThicknessData stroke, List<DataPoint> points) {
    double size = stroke.size;
    for (var point in points) {
      final override = point.thickness?.size;
      if (override != null && size != override) return false;
    }
    return true;
  }

  bool isSameStrokePainter(ThicknessData stroke, List<DataPoint> points) {
    Object painter = stroke.gradient ?? stroke.color;
    for (var point in points) {
      final override = point.thickness?.gradient ?? point.thickness?.color;
      if (override != null && painter != override) return false;
    }
    return true;
  }


  Path? _buildAreaPathBetweenFyAndY(LineData lineData, ChartRenderContext context) {
    final points = lineData.points;
    if (points.length < 2) return null;

    final topPath = lineData.lineType.toPath(points);
    final areaPath = Path.from(topPath);

    final last = points.last;
    areaPath.lineTo(last.x, last.y);

    lineData.lineType.toPath(points, useFy: false, reverse: true, path: areaPath);

    final first = points.first;
    areaPath.lineTo(first.x, first.fy);
    return areaPath;
  }



}
