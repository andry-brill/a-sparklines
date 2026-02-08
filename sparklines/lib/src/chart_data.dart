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
class BarData implements ISparklinesData, IChartBorder, IChartThickness {

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
  final bool? crop;
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

  @override
  final ThicknessData thickness;

  @override
  final ThicknessData? border;

  @override
  final double? borderRadius;

  const BarData({
    this.visible = true,
    this.rotation = 0.0,
    this.origin = Offset.zero,
    this.layout,
    this.crop,
    required this.bars,
    this.thickness = const ThicknessData(size: 2.0),
    this.border,
    this.borderRadius,
  });

  BarData copyWith({
    bool? visible,
    double? rotation,
    Offset? origin,
    IChartLayout? layout,
    bool? crop,
    List<DataPoint>? bars,
    ThicknessData? thickness,
    ThicknessData? border,
    double? borderRadius,
  }) {
    return BarData(
      visible: visible ?? this.visible,
      rotation: rotation ?? this.rotation,
      origin: origin ?? this.origin,
      layout: layout ?? this.layout,
      crop: crop ?? this.crop,
      bars: bars ?? this.bars,
      thickness: thickness ?? this.thickness,
      border: border ?? this.border,
      borderRadius: borderRadius ?? this.borderRadius,
    );
  }

  @override
  bool shouldRepaint(ISparklinesData other) {
    if (other is! BarData) return true;
    if (visible != other.visible) return true;
    if (rotation != other.rotation) return true;
    if (origin != other.origin) return true;
    if (layout != other.layout) return true;
    if (thickness != other) return true;
    if (bars.length != other.bars.length) return true;
    if (border != other.border) return true;
    if (borderRadius != other.borderRadius) return true;

    // Check if data points changed
    for (int i = 0; i < bars.length; i++) {
      if (bars[i].x != other.bars[i].x || bars[i].dy != other.bars[i].dy) {
        return true;
      }
    }

    return false;
  }

  @override
  ISparklinesData lerpTo(ISparklinesData next, double t) {
    if (next is! BarData) return next;
    if (bars.length != next.bars.length) return next;
    if (visible != next.visible) return next;

    final interpolatedBars = <DataPoint>[];
    for (int i = 0; i < bars.length; i++) {
      interpolatedBars.add(bars[i].lerpTo(next.bars[i], t));
    }

    return BarData(
      visible: next.visible,
      rotation: lerpDouble(rotation, next.rotation, t) ?? next.rotation,
      origin: Offset.lerp(origin, next.origin, t) ?? next.origin,
      layout: next.layout,
      crop: next.crop,
      bars: interpolatedBars,
      thickness: thickness.lerpTo(next.thickness, t),
      border: ThicknessData.lerp(border, next.border, t),
      borderRadius: lerpDouble(borderRadius, next.borderRadius, t) ?? next.borderRadius,
    );
  }


}

/// Line chart data
class LineData implements ISparklinesData, IChartThickness {
  static final LineChartRenderer defaultRenderer = LineChartRenderer();

  @override
  final bool visible;
  @override
  final double rotation;
  @override
  final Offset origin;
  @override
  final IChartLayout? layout;
  @override
  final bool? crop;

  @override
  LineChartRenderer get renderer => defaultRenderer;

  final List<DataPoint> points;

  @override
  double get minX => points.minX;

  @override
  double get maxX => points.maxX;

  @override
  double get minY => points.minY;

  @override
  double get maxY => points.maxY;

  @override
  final ThicknessData thickness;

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
    this.crop,
    required this.points,
    this.thickness = const ThicknessData(size: 2.0),
    this.gradientArea,
    this.lineType,
    this.isStrokeCapRound = false,
    this.isStrokeJoinRound = false,
    this.pointStyle,
  });

  LineData copyWith({
    bool? visible,
    double? rotation,
    Offset? origin,
    IChartLayout? layout,
    bool? crop,
    List<DataPoint>? points,
    ThicknessData? thickness,
    Gradient? gradientArea,
    ILineTypeData? lineType,
    bool? isStrokeCapRound,
    bool? isStrokeJoinRound,
    IDataPointStyle? pointStyle,
  }) {
    return LineData(
      visible: visible ?? this.visible,
      rotation: rotation ?? this.rotation,
      origin: origin ?? this.origin,
      layout: layout ?? this.layout,
      crop: crop ?? this.crop,
      points: points ?? this.points,
      thickness: thickness ?? this.thickness,
      gradientArea: gradientArea ?? this.gradientArea,
      lineType: lineType ?? this.lineType,
      isStrokeCapRound: isStrokeCapRound ?? this.isStrokeCapRound,
      isStrokeJoinRound: isStrokeJoinRound ?? this.isStrokeJoinRound,
      pointStyle: pointStyle ?? this.pointStyle,
    );
  }

  @override
  bool shouldRepaint(ISparklinesData other) {
    if (other is! LineData) return true;
    if (visible != other.visible) return true;
    if (rotation != other.rotation) return true;
    if (origin != other.origin) return true;
    if (layout != other.layout) return true;
    if (points.length != other.points.length) return true;
    if (!ThicknessData.isEquals(thickness, other.thickness)) return true;
    if (gradientArea != other.gradientArea) return true;
    if (lineType != other.lineType) return true;
    if (isStrokeCapRound != other.isStrokeCapRound) return true;
    if (isStrokeJoinRound != other.isStrokeJoinRound) return true;
    if (pointStyle != other.pointStyle) return true;

    // Check if data points changed
    for (int i = 0; i < points.length; i++) {
      if (points[i].x != other.points[i].x || points[i].dy != other.points[i].dy) {
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
      crop: next.crop,
      points: interpolatedPoints,
      thickness: thickness.lerpTo(next.thickness, t),
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
  final bool? crop;
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
    this.crop,
    required this.from,
    required this.to,
    this.color,
    this.gradient,
  });

  BetweenLineData copyWith({
    bool? visible,
    double? rotation,
    Offset? origin,
    IChartLayout? layout,
    bool? crop,
    LineData? from,
    LineData? to,
    Color? color,
    Gradient? gradient,
  }) {
    return BetweenLineData(
      visible: visible ?? this.visible,
      rotation: rotation ?? this.rotation,
      origin: origin ?? this.origin,
      layout: layout ?? this.layout,
      crop: crop ?? this.crop,
      from: from ?? this.from,
      to: to ?? this.to,
      color: color ?? this.color,
      gradient: gradient ?? this.gradient,
    );
  }

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
      crop: next.crop,
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
  final bool? crop;
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
    this.crop,
    required this.points,
    this.stroke = double.infinity,
    this.strokeAlign = StrokeAlign.center,
    this.color,
    this.gradient,
    this.space = 0.0,
    this.border,
    this.borderRadius,
    this.borderColor,
  });

  PieData copyWith({
    bool? visible,
    double? rotation,
    Offset? origin,
    IChartLayout? layout,
    bool? crop,
    List<DataPoint>? pies,
    double? stroke,
    StrokeAlign? strokeAlign,
    Color? color,
    Gradient? gradient,
    double? space,
    BorderSide? border,
    BorderRadius? borderRadius,
    Color? borderColor,
  }) {
    return PieData(
      visible: visible ?? this.visible,
      rotation: rotation ?? this.rotation,
      origin: origin ?? this.origin,
      layout: layout ?? this.layout,
      crop: crop ?? this.crop,
      points: pies ?? this.points,
      stroke: stroke ?? this.stroke,
      strokeAlign: strokeAlign ?? this.strokeAlign,
      color: color ?? this.color,
      gradient: gradient ?? this.gradient,
      space: space ?? this.space,
      border: border ?? this.border,
      borderRadius: borderRadius ?? this.borderRadius,
      borderColor: borderColor ?? this.borderColor,
    );
  }

  @override
  bool shouldRepaint(ISparklinesData other) {
    if (other is! PieData) return true;
    if (visible != other.visible) return true;
    if (rotation != other.rotation) return true;
    if (origin != other.origin) return true;
    if (layout != other.layout) return true;
    if (points.length != other.points.length) return true;
    if (stroke != other.stroke) return true;
    if (strokeAlign != other.strokeAlign) return true;
    if (color != other.color) return true;
    if (gradient != other.gradient) return true;
    if (space != other.space) return true;
    if (border != other.border) return true;
    if (borderRadius != other.borderRadius) return true;
    if (borderColor != other.borderColor) return true;

    // Check if data points changed
    for (int i = 0; i < points.length; i++) {
      if (points[i].x != other.points[i].x || points[i].dy != other.points[i].dy) {
        return true;
      }
    }

    return false;
  }

  @override
  ISparklinesData lerpTo(ISparklinesData next, double t) {
    if (next is! PieData) return next;
    if (points.length != next.points.length) return next;
    if (visible != next.visible) return next;

    final interpolatedPies = <DataPoint>[];
    for (int i = 0; i < points.length; i++) {
      interpolatedPies.add(points[i].lerpTo(next.points[i], t));
    }

    return PieData(
      visible: next.visible,
      rotation: lerpDouble(rotation, next.rotation, t) ?? next.rotation,
      origin: Offset.lerp(origin, next.origin, t) ?? next.origin,
      layout: next.layout,
      crop: next.crop,
      points: interpolatedPies,
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
