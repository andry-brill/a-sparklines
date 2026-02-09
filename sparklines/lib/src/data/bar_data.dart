import 'package:flutter/material.dart';
import 'dart:ui' show lerpDouble;
import 'data_point.dart';
import '../interfaces.dart';
import '../renderers/bar_chart_renderer.dart';

/// Bar chart data
class BarData implements ISparklinesData, IChartBorder, IChartThickness, IChartDataPointStyle {

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

  @override
  final IDataPointStyle? pointStyle;

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
    this.pointStyle
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
    IDataPointStyle? pointStyle
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
      pointStyle: pointStyle ?? this.pointStyle,
    );
  }

  @override
  bool shouldRepaint(ISparklinesData other) {
    if (other is! BarData) return true;
    if (visible != other.visible) return true;
    if (rotation != other.rotation) return true;
    if (origin != other.origin) return true;
    if (layout != other.layout) return true;
    if (thickness != other.thickness) return true;
    if (bars.length != other.bars.length) return true;
    if (border != other.border) return true;
    if (borderRadius != other.borderRadius) return true;
    if (pointStyle != other.pointStyle) return true;

    for (int i = 0; i < bars.length; i++) {
      if (bars[i] != other.bars[i]) {
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
      pointStyle: ILerpTo.lerp(pointStyle, next.pointStyle, t),
    );
  }
}
