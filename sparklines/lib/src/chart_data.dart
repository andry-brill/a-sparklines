import 'package:flutter/material.dart';
import 'dart:ui' show lerpDouble;
import 'data_point.dart';
import 'interfaces.dart';
import 'stroke_align.dart';

/// Bar chart data
class BarData implements ISparklinesData {
  @override
  final bool visible;
  @override
  final double rotation;
  @override
  final Offset origin;

  final List<DataPoint> bars;
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
  @override
  final bool visible;
  @override
  final double rotation;
  @override
  final Offset origin;

  final List<DataPoint> points;
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
  @override
  final bool visible;
  @override
  final double rotation;
  @override
  final Offset origin;

  final LineData from;
  final LineData to;
  final Color? color;
  final Gradient? gradient;

  const BetweenLineData({
    this.visible = true,
    this.rotation = 0.0,
    this.origin = Offset.zero,
    required this.from,
    required this.to,
    this.color,
    this.gradient,
  });

  @override
  ISparklinesData lerpTo(ISparklinesData next, double t) {
    if (next is! BetweenLineData) return next;
    if (visible != next.visible) return next;

    return BetweenLineData(
      visible: next.visible,
      rotation: lerpDouble(rotation, next.rotation, t) ?? next.rotation,
      origin: Offset.lerp(origin, next.origin, t) ?? next.origin,
      from: from.lerpTo(next.from, t) as LineData,
      to: to.lerpTo(next.to, t) as LineData,
      color: Color.lerp(color, next.color, t),
      gradient: Gradient.lerp(gradient, next.gradient, t),
    );
  }
}

/// Pie chart data
class PieData implements ISparklinesData {
  @override
  final bool visible;
  @override
  final double rotation;
  @override
  final Offset origin;

  final List<DataPoint> pies;
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
