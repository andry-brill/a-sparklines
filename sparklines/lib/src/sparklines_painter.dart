import 'package:flutter/material.dart';
import 'coordinate_transformer.dart';
import 'interfaces.dart';
import 'renderers/bar_chart_renderer.dart';
import 'renderers/line_chart_renderer.dart';
import 'renderers/between_line_renderer.dart';
import 'renderers/pie_chart_renderer.dart';
import 'chart_data.dart';

/// Custom painter for sparklines charts
class SparklinesPainter extends CustomPainter {
  final CoordinateTransformer transformer;
  final List<ISparklinesData> charts;
  final List<ISparklinesData>? oldCharts;

  final BarChartRenderer _barRenderer = BarChartRenderer();
  final LineChartRenderer _lineRenderer = LineChartRenderer();
  final BetweenLineRenderer _betweenRenderer = BetweenLineRenderer();
  final PieChartRenderer _pieRenderer = PieChartRenderer();

  SparklinesPainter({
    required this.transformer,
    required this.charts,
    this.oldCharts,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final chart in charts) {
      if (!chart.visible) continue;

      if (chart is BarData) {
        _barRenderer.render(canvas, transformer, chart);
      } else if (chart is LineData) {
        _lineRenderer.render(canvas, transformer, chart);
      } else if (chart is BetweenLineData) {
        _betweenRenderer.render(canvas, transformer, chart);
      } else if (chart is PieData) {
        _pieRenderer.render(canvas, transformer, chart);
      }
    }
  }

  @override
  bool shouldRepaint(SparklinesPainter oldDelegate) {
    // Repaint if transformer changed
    if (oldDelegate.transformer.width != transformer.width ||
        oldDelegate.transformer.height != transformer.height ||
        oldDelegate.transformer.minX != transformer.minX ||
        oldDelegate.transformer.maxX != transformer.maxX ||
        oldDelegate.transformer.minY != transformer.minY ||
        oldDelegate.transformer.maxY != transformer.maxY) {
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
