import 'package:flutter/material.dart';
import 'package:sparklines/src/data/layout_data.dart';
import 'interfaces.dart';

/// Custom painter for sparklines charts
class SparklinesPainter extends CustomPainter {
  final List<ISparklinesData> charts;
  final IChartLayout defaultLayout;
  final bool defaultCrop;
  final double width;
  final double height;
  final List<ISparklinesData>? oldCharts;

  SparklinesPainter({
    required this.charts,
    required this.defaultLayout,
    required this.defaultCrop,
    required this.width,
    required this.height,
    this.oldCharts,
  });

  LayoutData layoutData(ISparklinesData chart) => LayoutData(
    minX: chart.minX,
    maxX: chart.maxX,
    minY: chart.minY,
    maxY: chart.maxY,
    width: width,
    height: height,
  );

  @override
  void paint(Canvas canvas, Size size) {

    final Map<IChartLayout, List<LayoutData>> layouts = {};

    for (final chart in charts) {

      if (!chart.visible) continue;

      final chartLayout = chart.layout ?? defaultLayout;
      final datas = layouts.putIfAbsent(chartLayout, () => []);
      datas.add(layoutData(chart));

    }

    for (final chart in charts) {

      if (!chart.visible) continue;

      final originalLayout = chart.layout ?? defaultLayout;
      final layoutDatas = layouts[originalLayout]!;
      final chartLayout = originalLayout.resolve(layoutDatas);
      final chartCrop = chart.crop ?? defaultCrop;
      final context = ChartRenderContext(
        layout: chartLayout,
        dimensions: layoutData(chart),
        crop: chartCrop,
      );

      canvas.save();
      chart.renderer.render(canvas, context, chart);
      canvas.restore();
    }

  }

  @override
  bool shouldRepaint(SparklinesPainter oldDelegate) {

    if (oldDelegate.width != width || oldDelegate.height != height) {
      return true;
    }

    if (oldDelegate.defaultLayout != defaultLayout) {
      return true;
    }

    if (oldDelegate.defaultCrop != defaultCrop) {
      return true;
    }

    if (oldDelegate.charts.length != charts.length) {
      return true;
    }

    for (int i = 0; i < charts.length; i++) {
      if (charts[i].shouldRepaint(oldDelegate.charts[i])) {
        return true;
      }
    }

    return false;
  }
}
