import 'package:flutter/material.dart';
import 'package:sparklines/src/renderers/base_renderer.dart';
import '../coordinate_transformer.dart';
import '../chart_data.dart';
import 'line_chart_renderer.dart';

/// Renders area between two lines
class BetweenLineRenderer extends BaseRenderer<BetweenLineData> {

  @override
  void renderData(
    Canvas canvas,
    CoordinateTransformer transformer,
    BetweenLineData betweenData,
  ) {

    final paint = Paint();

    // Build path from 'from' line
    final fromPath = betweenData.from.renderer.buildPath(betweenData.from, transformer);

    // Build path from 'to' line (reversed)
    final toPath = betweenData.to.renderer.buildPath(betweenData.to, transformer);
    final reversedToPath = _reversePath(toPath);

    // Combine paths
    final combinedPath = Path.from(fromPath);
    combinedPath.addPath(reversedToPath, Offset.zero);
    combinedPath.close();

    // Fill the area
    if (betweenData.gradient != null) {
      paint.shader = betweenData.gradient!.createShader(
        Rect.fromLTWH(0, 0, transformer.width, transformer.height),
      );
    } else {
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
