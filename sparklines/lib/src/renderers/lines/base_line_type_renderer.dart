
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

  GradientStops toGradientGlobalStops(ThicknessData thickness) {

    Object paint = thickness.gradient ?? thickness.color;

    late List<Color> colors;

    List<double>? stops;
    if (paint is Gradient) {
      colors = prepareColors(paint.colors);
      stops = paint.stops;
    } else {
      colors = [paint as Color, paint];
    }

    return GradientStops(colors, stops ?? defaultStops(colors));

  }

  List<Color> prepareColors(List<Color> colors) {
    if (colors.isEmpty) throw 'Colors in gradient is empty';
    if (colors.length == 1) return [colors.first, colors.first];
    return colors;
  }

  List<double> defaultStops(List<Color> colors) {

    final n = colors.length;
    if (n == 0) return [];
    if (n == 1) return [0.0];

    final List<double> stops = List<double>.filled(n, 0.0);

    final step = 1.0 / (n - 1);
    for (int i = 1; i < n - 1; i++) {
      stops[i] = i * step;
    }

    stops[n - 1] = 1.0;

    return stops;
  }

  Gradient globalMixedGradient(ThicknessData global, List<DataPoint> points) {

    if (points.isEmpty) {
      return global.gradient ??
          LinearGradient(colors: [global.color, global.color]);
    }

    final globalStops = toGradientGlobalStops(global);

    final double startX = points.first.x;
    final double endX = points.last.x;
    final double length = (endX - startX).abs();

    if (points.length <= 1 || length <= 0.0001) {
      return LinearGradient(
        colors: globalStops.colors,
        stops: globalStops.stops,
      );
    }

    double normalize(double x) => (x - startX) / length;

    final List<double> stops = [];
    final List<Color> colors = [];

    for (int i = 0; i < points.length; i++) {

      final point = points[i];

      Object? localPaint = point.thickness?.gradient ?? point.thickness?.color;
      if (localPaint == null) {
        // no local gradient → sample global at point.x
        final tGlobal = normalize(point.x).clamp(0.0, 1.0);
        stops.add(tGlobal);
        colors.add(globalStops.sample(tGlobal));
      } else {

        if (localPaint is Gradient) {

          final prevX = i > 0 ? points[i - 1].x : double.nan;
          final nextX = i < points.length - 1 ? points[i + 1].x : double.nan;

          double left, right;
          double localStart, localEnd;

          if (!prevX.isNaN && !nextX.isNaN) {
            // has both prev and next → full gradient in interval
            left = normalize((prevX + point.x) / 2);
            right = normalize((point.x + nextX) / 2);
            localStart = 0.0;
            localEnd = 1.0;
          } else if (prevX.isNaN && !nextX.isNaN) {
            // first point → second half of local gradient
            left = normalize(point.x);
            right = normalize((point.x + nextX) / 2);
            localStart = 0.5;
            localEnd = 1.0;
          } else if (!prevX.isNaN && nextX.isNaN) {
            // last point → first half of local gradient
            left = normalize((prevX + point.x) / 2);
            right = normalize(point.x);
            localStart = 0.0;
            localEnd = 0.5;
          } else {
            throw 'WTF?';
          }

          final gColors = prepareColors(localPaint.colors);
          final localStops = GradientStops(gColors, localPaint.stops ?? defaultStops(gColors));

          for (int j = 0; j < localStops.stops.length; j++) {
            final tLocal = localStops.stops[j].clamp(0.0, 1.0);
            // map local [localStart..localEnd] → global [left..right]
            final tGlobal = left + ((tLocal * (localEnd - localStart)) + localStart) * (right - left);
            stops.add(tGlobal);
            colors.add(localStops.colors[j]);
          }
        }

        final localColor = localPaint as Color;
        final tGlobal = normalize(point.x).clamp(0.0, 1.0);
        stops.add(tGlobal);
        colors.add(localColor);
      }

    }

    return LinearGradient(colors: colors, stops: stops);
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

  bool renderDynamicPaint(ChartRenderContext context, LineData lineData, bool isDynamicStroke, bool isDynamicPaint) {

    if (isDynamicStroke || !isDynamicPaint) return false;

    final path = toPath(lineData.lineType, lineData.points);
    final tPath = path.transform(context.pathTransform.storage);

    final paint = buildStrokePaint(context, lineData);
    Gradient global = globalMixedGradient(lineData.thickness, lineData.points);
    paint.shader = global.createShader(tPath.getBounds());
    context.canvas.drawPath(tPath, paint);

    return true;
  }

  void renderComplexPath(ChartRenderContext context, LineData lineData, bool isDynamicStroke, bool isDynamicPaint);
}


class GradientStops {
  final List<Color> colors;
  final List<double> stops;

  const GradientStops(this.colors, this.stops) : assert(colors.length == stops.length);

  /// Sample color at normalized t [0..1]
  Color sample(double t) {
    if (t <= stops.first) return colors.first;
    if (t >= stops.last) return colors.last;

    for (int i = 0; i < stops.length - 1; i++) {
      final s0 = stops[i];
      final s1 = stops[i + 1];

      if (t >= s0 && t <= s1) {
        final localT = (t - s0) / (s1 - s0);
        return Color.lerp(colors[i], colors[i + 1], localT)!;
      }
    }
    return colors.last;
  }
}