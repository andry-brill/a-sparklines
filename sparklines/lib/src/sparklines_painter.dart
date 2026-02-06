import 'package:flutter/material.dart';
import 'coordinate_transformer.dart';
import 'interfaces.dart';

/// Custom painter for sparklines charts
class SparklinesPainter extends CustomPainter {
  final List<ISparklinesData> charts;
  final IChartLayout defaultLayout;
  final double width;
  final double height;
  final List<ISparklinesData>? oldCharts;

  SparklinesPainter({
    required this.charts,
    required this.defaultLayout,
    required this.width,
    required this.height,
    this.oldCharts,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final chart in charts) {
      if (!chart.visible) continue;

      // Get chart's layout or use default
      final chartLayout = chart.layout ?? defaultLayout;

      // Create transformer for this chart
      final transformer = CoordinateTransformer(
        minX: chart.minX,
        maxX: chart.maxX,
        minY: chart.minY,
        maxY: chart.maxY,
        width: width,
        height: height,
        layout: chartLayout,
      );

      // Render chart with its own transformer
      chart.renderer.render(canvas, transformer, chart);
    }
  }

  @override
  bool shouldRepaint(SparklinesPainter oldDelegate) {
    // Repaint if dimensions changed
    if (oldDelegate.width != width || oldDelegate.height != height) {
      return true;
    }

    // Repaint if default layout changed
    if (oldDelegate.defaultLayout != defaultLayout) {
      return true;
    }

    // Repaint if charts changed
    if (oldDelegate.charts.length != charts.length) {
      return true;
    }

    // Simple comparison - in production, you'd want deeper comparison
    for (int i = 0; i < charts.length; i++) {
      if (oldDelegate.charts[i] != charts[i]) {
        return true;
      }
    }

    return false;
  }
}
