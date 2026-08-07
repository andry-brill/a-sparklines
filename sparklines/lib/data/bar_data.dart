import 'dart:collection';

import 'package:any_sparklines/interfaces/data_point_data.dart';
import 'package:flutter/material.dart';
import '../interfaces/chart_border.dart';
import '../interfaces/chart_flip.dart';
import '../interfaces/chart_insets.dart';
import '../interfaces/chart_rotation.dart';
import '../interfaces/data_point_style.dart';
import '../interfaces/layout.dart';
import '../interfaces/length_value.dart';
import '../interfaces/lerp.dart';
import '../interfaces/sparklines_data.dart';
import '../interfaces/thickness.dart';
import '../renderers/bar_chart_renderer.dart';
import 'data_point.dart';

/// Bar chart data
class BarData with IterableMixin<DataPoint> implements ISparklinesData, IChartBorder, IChartThickness, IChartDataPointStyle {

  static final IChartRenderer defaultRenderer = BarChartRenderer();

  @override
  final bool visible;
  @override
  final ChartRotation rotation;
  @override
  final ChartFlip flip;
  @override
  final Offset origin;
  @override
  final IChartLayout? layout;
  @override
  final bool? crop;
  @override
  final ChartInsets padding;
  @override
  IChartRenderer get renderer => defaultRenderer;

  final List<DataPoint> bars;

  @override
  Iterator<DataPoint> get iterator => bars.iterator;
  @override
  bool get supportsPointExtents => true;

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
  final ILengthValue? borderRadius;

  @override
  final IDataPointStyle? pointStyle;

  const BarData({
    this.visible = true,
    this.rotation = ChartRotation.d0,
    this.flip = ChartFlip.none,
    this.origin = Offset.zero,
    this.layout,
    this.crop,
    this.padding = const ChartInsets(),
    required this.bars,
    this.thickness = const ThicknessData(size: Px(2.0)),
    this.border,
    this.borderRadius,
    this.pointStyle
  });

  BarData copyWith({
    bool? visible,
    ChartRotation? rotation,
    ChartFlip? flip,
    Offset? origin,
    IChartLayout? layout,
    bool? crop,
    ChartInsets? padding,
    List<DataPoint>? bars,
    ThicknessData? thickness,
    ThicknessData? border,
    ILengthValue? borderRadius,
    IDataPointStyle? pointStyle
  }) {
    return BarData(
      visible: visible ?? this.visible,
      rotation: rotation ?? this.rotation,
      flip: flip ?? this.flip,
      origin: origin ?? this.origin,
      layout: layout ?? this.layout,
      crop: crop ?? this.crop,
      padding: padding ?? this.padding,
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
    if (flip != other.flip) return true;
    if (origin != other.origin) return true;
    if (layout != other.layout) return true;
    if (padding != other.padding) return true;
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
      rotation: next.rotation,
      flip: next.flip,
      origin: Offset.lerp(origin, next.origin, t) ?? next.origin,
      layout: next.layout,
      crop: next.crop,
      padding: padding.lerp(next.padding, t),
      bars: interpolatedBars,
      thickness: thickness.lerpTo(next.thickness, t),
      border: ILerpTo.lerp(border, next.border, t),
      borderRadius: ILengthValue.lerp(borderRadius, next.borderRadius, t),
      pointStyle: ILerpTo.lerp<IDataPointData>(pointStyle, next.pointStyle, t) as IDataPointStyle?,
    );
  }
}
