import 'package:flutter/material.dart';
import 'dart:ui' show lerpDouble;
import 'dart:math' as math;
import 'data_point.dart';
import 'interfaces.dart';
import 'stroke_align.dart';
import 'renderers/bar_chart_renderer.dart';
import 'renderers/line_chart_renderer.dart';
import 'renderers/between_line_renderer.dart';
import 'renderers/pie_chart_renderer.dart';

/// Bar chart data
class BarData implements ISparklinesData {
  static final IChartRenderer defaultRenderer = BarChartRenderer();

  @override
  final bool visible;
  @override
  final double rotation;
  @override
  final Offset origin;
  @override
  final IChartLayout? layout;
  @override
  IChartRenderer get renderer => defaultRenderer;

  final List<DataPoint> bars;

  @override
  double get minX => bars.minX;

  @override
  double get maxX => bars.maxX;

  @override
  double get minY => bars.minY;

  @override
  double get maxY => bars.maxY;
  final bool stacked;
  final double width;
  final Color? color;
  final Gradient? gradient;
  final BorderSide? border;
  final BorderRadius? borderRadius;
  final Color? borderColor;

  const BarData({
    this.visible = true,
    this.rotation = 0.0,
    this.origin = Offset.zero,
    this.layout,
    required this.bars,
    this.stacked = false,
    required this.width,
    this.color,
    this.gradient,
    this.border,
    this.borderRadius,
    this.borderColor,
  });

  @override
  bool shouldRepaint(ISparklinesData other) {
    if (other is! BarData) return true;
    if (visible != other.visible) return true;
    if (rotation != other.rotation) return true;
    if (origin != other.origin) return true;
    if (layout != other.layout) return true;
    if (stacked != other.stacked) return true;
    if (width != other.width) return true;
    if (bars.length != other.bars.length) return true;
    if (color != other.color) return true;
    if (gradient != other.gradient) return true;
    if (border != other.border) return true;
    if (borderRadius != other.borderRadius) return true;
    if (borderColor != other.borderColor) return true;

    // Check if data points changed
    for (int i = 0; i < bars.length; i++) {
      if (bars[i].x != other.bars[i].x || bars[i].y != other.bars[i].y) {
        return true;
      }
    }

    return false;
  }

  @override
  ISparklinesData lerpTo(ISparklinesData next, double t) {
    if (next is! BarData) return next;
    if (bars.length != next.bars.length) return next;
    if (visible != next.visible || stacked != next.stacked) return next;

    final interpolatedBars = <DataPoint>[];
    for (int i = 0; i < bars.length; i++) {
      interpolatedBars.add(bars[i].lerpTo(next.bars[i], t));
    }

    return BarData(
      visible: next.visible,
      rotation: lerpDouble(rotation, next.rotation, t) ?? next.rotation,
      origin: Offset.lerp(origin, next.origin, t) ?? next.origin,
      layout: next.layout,
      bars: interpolatedBars,
      stacked: next.stacked,
      width: lerpDouble(width, next.width, t) ?? next.width,
      color: Color.lerp(color, next.color, t),
      gradient: Gradient.lerp(gradient, next.gradient, t),
      border: border != null && next.border != null
          ? BorderSide.lerp(border!, next.border!, t)
          : next.border,
      borderRadius: BorderRadius.lerp(borderRadius, next.borderRadius, t),
      borderColor: Color.lerp(borderColor, next.borderColor, t),
    );
  }
}

/// Line chart data
class LineData implements ISparklinesData {
  static final IChartRenderer defaultRenderer = LineChartRenderer();

  @override
  final bool visible;
  @override
  final double rotation;
  @override
  final Offset origin;
  @override
  final IChartLayout? layout;
  @override
  IChartRenderer get renderer => defaultRenderer;

  final List<DataPoint> points;

  @override
  double get minX => points.minX;

  @override
  double get maxX => points.maxX;

  @override
  double get minY => points.minY;

  @override
  double get maxY => points.maxY;
  final Color? color;
  final double width;
  final Gradient? gradient;
  final Gradient? gradientArea;
  final ILineTypeData? lineType;
  final bool isStrokeCapRound;
  final bool isStrokeJoinRound;
  final IDataPointStyle? pointStyle;

  const LineData({
    this.visible = true,
    this.rotation = 0.0,
    this.origin = Offset.zero,
    this.layout,
    required this.points,
    this.color,
    this.width = 2.0,
    this.gradient,
    this.gradientArea,
    this.lineType,
    this.isStrokeCapRound = false,
    this.isStrokeJoinRound = false,
    this.pointStyle,
  });

  @override
  bool shouldRepaint(ISparklinesData other) {
    if (other is! LineData) return true;
    if (visible != other.visible) return true;
    if (rotation != other.rotation) return true;
    if (origin != other.origin) return true;
    if (layout != other.layout) return true;
    if (points.length != other.points.length) return true;
    if (color != other.color) return true;
    if (width != other.width) return true;
    if (gradient != other.gradient) return true;
    if (gradientArea != other.gradientArea) return true;
    if (lineType != other.lineType) return true;
    if (isStrokeCapRound != other.isStrokeCapRound) return true;
    if (isStrokeJoinRound != other.isStrokeJoinRound) return true;
    if (pointStyle != other.pointStyle) return true;

    // Check if data points changed
    for (int i = 0; i < points.length; i++) {
      if (points[i].x != other.points[i].x || points[i].y != other.points[i].y) {
        return true;
      }
    }

    return false;
  }

  @override
  ISparklinesData lerpTo(ISparklinesData next, double t) {
    if (next is! LineData) return next;
    if (points.length != next.points.length) return next;
    if (visible != next.visible) return next;

    final interpolatedPoints = <DataPoint>[];
    for (int i = 0; i < points.length; i++) {
      interpolatedPoints.add(points[i].lerpTo(next.points[i], t));
    }

    return LineData(
      visible: next.visible,
      rotation: lerpDouble(rotation, next.rotation, t) ?? next.rotation,
      origin: Offset.lerp(origin, next.origin, t) ?? next.origin,
      layout: next.layout,
      points: interpolatedPoints,
      color: Color.lerp(color, next.color, t),
      width: lerpDouble(width, next.width, t) ?? next.width,
      gradient: Gradient.lerp(gradient, next.gradient, t),
      gradientArea: Gradient.lerp(gradientArea, next.gradientArea, t),
      lineType: next.lineType,
      isStrokeCapRound: next.isStrokeCapRound,
      isStrokeJoinRound: next.isStrokeJoinRound,
      pointStyle: pointStyle != null && next.pointStyle != null
          ? pointStyle!.lerpTo(next.pointStyle!, t)
          : next.pointStyle,
    );
  }
}

/// Between line chart data (fills area between two lines)
class BetweenLineData implements ISparklinesData {
  static final IChartRenderer defaultRenderer = BetweenLineRenderer();

  @override
  final bool visible;
  @override
  final double rotation;
  @override
  final Offset origin;
  @override
  final IChartLayout? layout;
  @override
  IChartRenderer get renderer => defaultRenderer;

  final LineData from;
  final LineData to;

  @override
  double get minX => math.min(from.minX, to.minX);

  @override
  double get maxX => math.max(from.maxX, to.maxX);

  @override
  double get minY => math.min(from.minY, to.minY);

  @override
  double get maxY => math.max(from.maxY, to.maxY);
  final Color? color;
  final Gradient? gradient;

  const BetweenLineData({
    this.visible = true,
    this.rotation = 0.0,
    this.origin = Offset.zero,
    this.layout,
    required this.from,
    required this.to,
    this.color,
    this.gradient,
  });

  @override
  bool shouldRepaint(ISparklinesData other) {
    if (other is! BetweenLineData) return true;
    if (visible != other.visible) return true;
    if (rotation != other.rotation) return true;
    if (origin != other.origin) return true;
    if (layout != other.layout) return true;
    if (color != other.color) return true;
    if (gradient != other.gradient) return true;

    // Check if nested line data changed
    if (from.shouldRepaint(other.from) || to.shouldRepaint(other.to)) {
      return true;
    }

    return false;
  }

  @override
  ISparklinesData lerpTo(ISparklinesData next, double t) {
    if (next is! BetweenLineData) return next;
    if (visible != next.visible) return next;

    return BetweenLineData(
      visible: next.visible,
      rotation: lerpDouble(rotation, next.rotation, t) ?? next.rotation,
      origin: Offset.lerp(origin, next.origin, t) ?? next.origin,
      layout: next.layout,
      from: from.lerpTo(next.from, t) as LineData,
      to: to.lerpTo(next.to, t) as LineData,
      color: Color.lerp(color, next.color, t),
      gradient: Gradient.lerp(gradient, next.gradient, t),
    );
  }
}

/// Pie chart data
class PieData implements ISparklinesData {
  static final IChartRenderer defaultRenderer = PieChartRenderer();

  @override
  final bool visible;
  @override
  final double rotation;
  @override
  final Offset origin;
  @override
  final IChartLayout? layout;
  @override
  IChartRenderer get renderer => defaultRenderer;

  final List<DataPoint> pies;

  @override
  double get minX => pies.minX;

  @override
  double get maxX => pies.maxX;

  @override
  double get minY => pies.minY;

  @override
  double get maxY => pies.maxY;
  final double stroke;
  final StrokeAlign strokeAlign;
  final Color? color;
  final Gradient? gradient;
  final double space;
  final BorderSide? border;
  final BorderRadius? borderRadius;
  final Color? borderColor;

  const PieData({
    this.visible = true,
    this.rotation = 0.0,
    this.origin = Offset.zero,
    this.layout,
    required this.pies,
    this.stroke = double.infinity,
    this.strokeAlign = StrokeAlign.center,
    this.color,
    this.gradient,
    this.space = 0.0,
    this.border,
    this.borderRadius,
    this.borderColor,
  });

  @override
  bool shouldRepaint(ISparklinesData other) {
    if (other is! PieData) return true;
    if (visible != other.visible) return true;
    if (rotation != other.rotation) return true;
    if (origin != other.origin) return true;
    if (layout != other.layout) return true;
    if (pies.length != other.pies.length) return true;
    if (stroke != other.stroke) return true;
    if (strokeAlign != other.strokeAlign) return true;
    if (color != other.color) return true;
    if (gradient != other.gradient) return true;
    if (space != other.space) return true;
    if (border != other.border) return true;
    if (borderRadius != other.borderRadius) return true;
    if (borderColor != other.borderColor) return true;

    // Check if data points changed
    for (int i = 0; i < pies.length; i++) {
      if (pies[i].x != other.pies[i].x || pies[i].y != other.pies[i].y) {
        return true;
      }
    }

    return false;
  }

  @override
  ISparklinesData lerpTo(ISparklinesData next, double t) {
    if (next is! PieData) return next;
    if (pies.length != next.pies.length) return next;
    if (visible != next.visible) return next;

    final interpolatedPies = <DataPoint>[];
    for (int i = 0; i < pies.length; i++) {
      interpolatedPies.add(pies[i].lerpTo(next.pies[i], t));
    }

    return PieData(
      visible: next.visible,
      rotation: lerpDouble(rotation, next.rotation, t) ?? next.rotation,
      origin: Offset.lerp(origin, next.origin, t) ?? next.origin,
      layout: next.layout,
      pies: interpolatedPies,
      stroke: lerpDouble(stroke, next.stroke, t) ?? next.stroke,
      strokeAlign: next.strokeAlign,
      color: Color.lerp(color, next.color, t),
      gradient: Gradient.lerp(gradient, next.gradient, t),
      space: lerpDouble(space, next.space, t) ?? next.space,
      border: border != null && next.border != null
          ? BorderSide.lerp(border!, next.border!, t)
          : next.border,
      borderRadius: BorderRadius.lerp(borderRadius, next.borderRadius, t),
      borderColor: Color.lerp(borderColor, next.borderColor, t),
    );
  }
}
