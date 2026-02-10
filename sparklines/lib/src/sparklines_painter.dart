
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

  /// Dimensions for layout: for d90/d270, width and height are swapped so the chart fills bounds when rotated.
  LayoutData layoutData(ISparklinesData chart) {
    final r = chart.rotation;
    final logicalWidth = (r == ChartRotation.d90 || r == ChartRotation.d270) ? height : width;
    final logicalHeight = (r == ChartRotation.d90 || r == ChartRotation.d270) ? width : height;
    return LayoutData(
      minX: chart.minX,
      maxX: chart.maxX,
      minY: chart.minY,
      maxY: chart.maxY,
      width: logicalWidth,
      height: logicalHeight,
    );
  }

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
      final dimensions = layoutData(chart);

      canvas.save();

      final bounds = Rect.fromLTWH(0, 0, width, height);

      if (chart.crop ?? defaultCrop) {
        canvas.clipRect(bounds);
      }

      canvas.translate(chart.origin.dx, chart.origin.dy);

      final rotation = chart.rotation.angle;
      if (rotation != 0.0) {
        final center = bounds.center;
        canvas.translate(center.dx, center.dy);
        canvas.rotate(rotation);
        canvas.translate(-center.dx, -center.dy);

        if (chart.rotation == ChartRotation.d90 || chart.rotation == ChartRotation.d270) {
          // NB! Coordinates is rotated
          // NB! Fixing blank alignment in case of rotated charts as width and height is swapped
          canvas.translate(-(height - width)/2, -(width - height)/2);
        }
      }

      // Rotation and dimension swap (d90/d270) are applied by the painter before calling render.
      // chartLayout.prepare(canvas, dimensions);

      final context = ChartRenderContext(
        layout: chartLayout,
        dimensions: dimensions,
        pathTransform: chartLayout.pathTransform(canvas, dimensions),
        canvas: canvas
      );

      chart.renderer.render(context, chart);

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
