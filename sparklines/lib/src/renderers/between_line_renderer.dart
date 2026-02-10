import 'package:flutter/material.dart';
import 'package:sparklines/src/data/between_line_data.dart';
import 'package:sparklines/src/interfaces.dart';
import 'package:sparklines/src/renderers/chart_renderer.dart';
/// Renders area between two lines
class BetweenLineRenderer extends AChartRenderer<BetweenLineData> {
  @override
  void renderData(
    Canvas canvas,
    ChartRenderContext context,
    BetweenLineData betweenData,
  ) {
    final paint = Paint();

    final fromPath = betweenData.from.renderer.buildPath(betweenData.from, context);
    final toPath = betweenData.to.renderer.buildPath(betweenData.to, context);
    final reversedToPath = _reversePath(toPath);

    final combinedPath = Path.from(fromPath);
    combinedPath.addPath(reversedToPath, Offset.zero);
    combinedPath.close();

    if (betweenData.gradient != null) {
      paint.shader = betweenData.gradient!.createShader(context.bounds);
    } else {
      paint.shader = null;
      paint.color = betweenData.color ?? Colors.blue.withValues(alpha: 0.3);
    }

    paint.style = PaintingStyle.fill;
    canvas.drawPath(combinedPath, paint);
  }

  Path _reversePath(Path path) {
    // Build reversed path by sampling points along the path
    final reversed = Path();
    final metrics = path.computeMetrics();

    for (final metric in metrics) {
      if (metric.length == 0) continue;

      // Sample points along the path
      final sampleCount = (metric.length / 2).ceil().clamp(10, 100);
      final points = <Offset>[];

      for (int i = 0; i <= sampleCount; i++) {
        final t = i / sampleCount;
        final tangent = metric.getTangentForOffset(metric.length * t);
        if (tangent != null) {
          points.add(tangent.position);
        }
      }

      // Build reversed path
      if (points.isNotEmpty) {
        reversed.moveTo(points.last.dx, points.last.dy);
        for (int i = points.length - 2; i >= 0; i--) {
          reversed.lineTo(points[i].dx, points[i].dy);
        }
      }
    }

    return reversed;
  }
}
