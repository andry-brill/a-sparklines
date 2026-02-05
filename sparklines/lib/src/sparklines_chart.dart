import 'dart:ui' show lerpDouble;
import 'package:flutter/material.dart';
import 'coordinate_transformer.dart';
import 'interfaces.dart';
import 'chart_data.dart';
import 'data_point.dart';
import 'sparklines_painter.dart';

/// Main sparklines chart widget
class SparklinesChart extends StatefulWidget {
  final double? width;
  final double? height;
  final double? aspectRatio;

  final double minX;
  final double maxX;
  final double minY;
  final double maxY;

  final bool crop;
  final bool relativeDataPoints;
  final bool relativeDimensions;

  final Duration animationDuration;
  final Curve animationCurve;
  final bool animate;

  final List<ISparklinesData> charts;

  const SparklinesChart({
    super.key,
    this.width,
    this.height,
    this.aspectRatio,
    this.minX = 0.0,
    this.maxX = 1.0,
    this.minY = 0.0,
    this.maxY = 1.0,
    this.crop = false,
    this.relativeDataPoints = true,
    this.relativeDimensions = true,
    this.animationDuration = const Duration(milliseconds: 300),
    this.animationCurve = Curves.easeInOut,
    this.animate = true,
    required this.charts,
  }) : assert(minX < maxX, 'minX must be less than maxX'),
       assert(minY < maxY, 'minY must be less than maxY');

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
    if (oldChart is BarData && newChart is BarData) {
      return _interpolateBarData(oldChart, newChart, t);
    } else if (oldChart is LineData && newChart is LineData) {
      return _interpolateLineData(oldChart, newChart, t);
    } else if (oldChart is PieData && newChart is PieData) {
      return _interpolatePieData(oldChart, newChart, t);
    }

    return newChart;
  }

  BarData _interpolateBarData(BarData old, BarData new_, double t) {
    if (old.bars.length != new_.bars.length) return new_;

    final interpolatedBars = <DataPoint>[];
    for (int i = 0; i < old.bars.length; i++) {
      interpolatedBars.add(DataPoint(
        x: new_.bars[i].x,
        y: lerpDouble(old.bars[i].y, new_.bars[i].y, t) ?? new_.bars[i].y,
        style: new_.bars[i].style,
      ));
    }

    return BarData(
      visible: new_.visible,
      rotation: lerpDouble(old.rotation, new_.rotation, t) ?? new_.rotation,
      origin: Offset.lerp(old.origin, new_.origin, t) ?? new_.origin,
      bars: interpolatedBars,
      stacked: new_.stacked,
      width: lerpDouble(old.width, new_.width, t) ?? new_.width,
      color: Color.lerp(old.color, new_.color, t),
      gradient: new_.gradient, // Gradients are not interpolated
      border: new_.border,
      borderRadius: new_.borderRadius,
      borderColor: Color.lerp(old.borderColor, new_.borderColor, t),
    );
  }

  LineData _interpolateLineData(LineData old, LineData new_, double t) {
    if (old.points.length != new_.points.length) return new_;

    final interpolatedPoints = <DataPoint>[];
    for (int i = 0; i < old.points.length; i++) {
      interpolatedPoints.add(DataPoint(
        x: new_.points[i].x,
        y: lerpDouble(old.points[i].y, new_.points[i].y, t) ?? new_.points[i].y,
        style: new_.points[i].style,
      ));
    }

    return LineData(
      visible: new_.visible,
      rotation: lerpDouble(old.rotation, new_.rotation, t) ?? new_.rotation,
      origin: Offset.lerp(old.origin, new_.origin, t) ?? new_.origin,
      points: interpolatedPoints,
      color: Color.lerp(old.color, new_.color, t),
      width: lerpDouble(old.width, new_.width, t) ?? new_.width,
      gradient: new_.gradient,
      gradientArea: new_.gradientArea,
      lineType: new_.lineType,
      isStrokeCapRound: new_.isStrokeCapRound,
      isStrokeJoinRound: new_.isStrokeJoinRound,
      pointStyle: new_.pointStyle,
    );
  }

  PieData _interpolatePieData(PieData old, PieData new_, double t) {
    if (old.pies.length != new_.pies.length) return new_;

    final interpolatedPies = <DataPoint>[];
    for (int i = 0; i < old.pies.length; i++) {
      interpolatedPies.add(DataPoint(
        x: lerpDouble(old.pies[i].x, new_.pies[i].x, t) ?? new_.pies[i].x,
        y: lerpDouble(old.pies[i].y, new_.pies[i].y, t) ?? new_.pies[i].y,
        style: new_.pies[i].style,
      ));
    }

    return PieData(
      visible: new_.visible,
      rotation: lerpDouble(old.rotation, new_.rotation, t) ?? new_.rotation,
      origin: Offset.lerp(old.origin, new_.origin, t) ?? new_.origin,
      pies: interpolatedPies,
      stroke: lerpDouble(old.stroke, new_.stroke, t) ?? new_.stroke,
      strokeAlign: new_.strokeAlign,
      color: Color.lerp(old.color, new_.color, t),
      gradient: new_.gradient,
      space: lerpDouble(old.space, new_.space, t) ?? new_.space,
      border: new_.border,
      borderRadius: new_.borderRadius,
      borderColor: Color.lerp(old.borderColor, new_.borderColor, t),
    );
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
      minX: widget.minX,
      maxX: widget.maxX,
      minY: widget.minY,
      maxY: widget.maxY,
      crop: widget.crop,
      relativeDataPoints: widget.relativeDataPoints,
      relativeDimensions: widget.relativeDimensions,
      animation: widget.animate ? _animation : const AlwaysStoppedAnimation(1.0),
      getCharts: _getInterpolatedCharts,
    );
  }
}

class _SparklinesRenderWidget extends StatelessWidget {
  final double? width;
  final double? height;
  final double? aspectRatio;
  final double minX;
  final double maxX;
  final double minY;
  final double maxY;
  final bool crop;
  final bool relativeDataPoints;
  final bool relativeDimensions;
  final Animation<double> animation;
  final List<ISparklinesData> Function(double) getCharts;

  const _SparklinesRenderWidget({
    required this.width,
    required this.height,
    required this.aspectRatio,
    required this.minX,
    required this.maxX,
    required this.minY,
    required this.maxY,
    required this.crop,
    required this.relativeDataPoints,
    required this.relativeDimensions,
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
        final transformer = CoordinateTransformer(
          minX: minX,
          maxX: maxX,
          minY: minY,
          maxY: maxY,
          width: w,
          height: h,
          relativeDataPoints: relativeDataPoints,
          relativeDimensions: relativeDimensions,
          crop: crop,
        );

        return CustomPaint(
          size: Size(w, h),
          painter: SparklinesPainter(
            transformer: transformer,
            charts: charts,
          ),
        );
      },
    );
  }
}
