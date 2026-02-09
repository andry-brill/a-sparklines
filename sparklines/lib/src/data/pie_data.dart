import 'package:flutter/material.dart';
import 'dart:ui' show lerpDouble;
import 'data_point.dart';
import '../interfaces.dart';
import '../renderers/pie_chart_renderer.dart';

/// Pie chart data
class PieData implements ISparklinesData, IChartThickness, IChartBorder {
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

  @override
  final ThicknessData thickness;

  final double space;

  @override
  final ThicknessData? border;
  @override
  final double? borderRadius;

  const PieData({
    this.visible = true,
    this.rotation = 0.0,
    this.origin = Offset.zero,
    this.layout,
    this.crop,
    required this.points,
    this.thickness = const ThicknessData(size: double.infinity, color: Color(0xFF2196F3)),
    this.space = 0.0,
    this.border,
    this.borderRadius,
  });

  PieData copyWith({
    bool? visible,
    double? rotation,
    Offset? origin,
    IChartLayout? layout,
    bool? crop,
    List<DataPoint>? points,
    ThicknessData? thickness,
    double? space,
    ThicknessData? border,
    double? borderRadius,
  }) {
    return PieData(
      visible: visible ?? this.visible,
      rotation: rotation ?? this.rotation,
      origin: origin ?? this.origin,
      layout: layout ?? this.layout,
      crop: crop ?? this.crop,
      points: points ?? this.points,
      thickness: thickness ?? this.thickness,
      space: space ?? this.space,
      border: border ?? this.border,
      borderRadius: borderRadius ?? this.borderRadius,
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
    if (thickness != other.thickness) return true;
    if (space != other.space) return true;
    if (border != other.border) return true;
    if (borderRadius != other.borderRadius) return true;

    for (int i = 0; i < points.length; i++) {
      if (points[i] != other.points[i]) {
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
      thickness: thickness.lerpTo(next.thickness, t),
      space: lerpDouble(space, next.space, t) ?? next.space,
      border: ThicknessData.lerp(border, next.border, t),
      borderRadius: lerpDouble(borderRadius, next.borderRadius, t) ?? next.borderRadius,
    );
  }
}
