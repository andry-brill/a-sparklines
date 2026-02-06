import 'package:flutter/material.dart';
import 'interfaces.dart';
import 'sparklines_painter.dart';
import 'chart_layout.dart';

/// Main sparklines chart widget
class SparklinesChart extends StatefulWidget {

  final double? width;
  final double? height;
  final double? aspectRatio;

  final IChartLayout layout;
  final bool crop;

  final Duration animationDuration;
  final Curve animationCurve;
  final bool animate;

  final List<ISparklinesData> charts;

  const SparklinesChart({
    super.key,
    this.width,
    this.height,
    this.aspectRatio,
    this.layout = const DefaultLayout(),
    this.crop = false,
    this.animationDuration = const Duration(milliseconds: 300),
    this.animationCurve = Curves.easeInOut,
    this.animate = true,
    required this.charts,
  });

  @override
  State<SparklinesChart> createState() => _SparklinesChartState();
}

class _SparklinesChartState extends State<SparklinesChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  List<ISparklinesData>? _oldCharts;
  List<ISparklinesData> _currentCharts = [];

  @override
  void initState() {
    super.initState();
    _currentCharts = widget.charts;
    _animationController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: widget.animationCurve,
    );
  }

  @override
  void didUpdateWidget(SparklinesChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.animate && _shouldAnimate(oldWidget.charts, widget.charts)) {
      _oldCharts = List.from(oldWidget.charts);
      _currentCharts = widget.charts;
      _animationController.forward(from: 0.0);
    } else {
      _currentCharts = widget.charts;
      _oldCharts = null;
    }
  }

  bool _shouldAnimate(
    List<ISparklinesData> oldCharts,
    List<ISparklinesData> newCharts,
  ) {
    if (oldCharts.length != newCharts.length) return true;

    for (int i = 0; i < oldCharts.length; i++) {
      if (oldCharts[i].runtimeType != newCharts[i].runtimeType) {
        return true;
      }
    }

    return true; // Always animate for now (can be optimized)
  }

  List<ISparklinesData> _getInterpolatedCharts(double t) {
    if (!widget.animate || _oldCharts == null || t >= 1.0) {
      return _currentCharts;
    }

    if (t <= 0.0) {
      return _oldCharts!;
    }

    // Interpolate between old and new charts
    final interpolated = <ISparklinesData>[];

    for (int i = 0; i < _currentCharts.length; i++) {
      if (i < _oldCharts!.length &&
          _oldCharts![i].runtimeType == _currentCharts[i].runtimeType) {
        interpolated.add(_interpolateChart(_oldCharts![i], _currentCharts[i], t));
      } else {
        interpolated.add(_currentCharts[i]);
      }
    }

    return interpolated;
  }

  ISparklinesData _interpolateChart(
    ISparklinesData oldChart,
    ISparklinesData newChart,
    double t,
  ) {
    return oldChart.lerpTo(newChart, t);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _SparklinesRenderWidget(
      width: widget.width,
      height: widget.height,
      aspectRatio: widget.aspectRatio,
      layout: widget.layout,
      crop: widget.crop,
      animation: widget.animate ? _animation : const AlwaysStoppedAnimation(1.0),
      getCharts: _getInterpolatedCharts,
    );
  }
}

class _SparklinesRenderWidget extends StatelessWidget {
  final double? width;
  final double? height;
  final double? aspectRatio;
  final IChartLayout layout;
  final bool crop;
  final Animation<double> animation;
  final List<ISparklinesData> Function(double) getCharts;

  const _SparklinesRenderWidget({
    required this.width,
    required this.height,
    required this.aspectRatio,
    required this.layout,
    required this.crop,
    required this.animation,
    required this.getCharts,
  });

  @override
  Widget build(BuildContext context) {
    if (width != null && height != null) {
      return _buildFixedSize();
    } else if (width != null || height != null) {
      return _buildOneDimension();
    } else {
      return _buildFlexible();
    }
  }

  Widget _buildFixedSize() {
    return SizedBox(
      width: width,
      height: height,
      child: _buildPainter(width!, height!),
    );
  }

  Widget _buildOneDimension() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = width ?? constraints.maxWidth;
        final h = height ?? constraints.maxHeight;
        return _buildPainter(w, h);
      },
    );
  }

  Widget _buildFlexible() {
    return LayoutBuilder(
      builder: (context, constraints) {
        double w = constraints.maxWidth;
        double h = constraints.maxHeight;

        if (aspectRatio != null) {
          if (w / h > aspectRatio!) {
            h = w / aspectRatio!;
          } else {
            w = h * aspectRatio!;
          }
        }

        return _buildPainter(w, h);
      },
    );
  }

  Widget _buildPainter(double w, double h) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {

        final charts = getCharts(animation.value);

        return CustomPaint(
          size: Size(w, h),
          painter: SparklinesPainter(
            charts: charts,
            defaultLayout: layout,
            defaultCrop: crop,
            width: w,
            height: h,
          ),
        );
      },
    );
  }
}
