import 'package:flutter/material.dart';
import 'data_point.dart';
import '../interfaces.dart';
import '../renderers/line_chart_renderer.dart';

/// Line chart data
class LineData implements ISparklinesData, IChartThickness, IChartDataPointStyle {

  static final LineChartRenderer defaultRenderer = LineChartRenderer();

  @override
  final bool visible;
  @override
  final ChartRotation rotation;
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

  final Gradient? areaGradient;
  final Color? areaColor;

  final ILineTypeData lineType;

  @override
  final IDataPointStyle? pointStyle;

  const LineData({
    this.visible = true,
    this.rotation = ChartRotation.d0,
    this.origin = Offset.zero,
    this.layout,
    this.crop,
    required this.points,
    this.thickness = const ThicknessData(size: 2.0),
    this.areaGradient,
    this.areaColor,
    this.lineType = const LinearLineType(),
    this.pointStyle,
  });

  LineData copyWith({
    bool? visible,
    ChartRotation? rotation,
    Offset? origin,
    IChartLayout? layout,
    bool? crop,
    List<DataPoint>? points,
    ThicknessData? thickness,
    Gradient? areaGradient,
    Color? areaColor,
    ILineTypeData? lineType,
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
      areaGradient: areaGradient ?? this.areaGradient,
      areaColor: areaColor ?? this.areaColor,
      lineType: lineType ?? this.lineType,
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
    if (thickness != other.thickness) return true;
    if (areaGradient != other.areaGradient) return true;
    if (areaColor != other.areaColor) return true;
    if (lineType != other.lineType) return true;
    if (pointStyle != other.pointStyle) return true;

    for (int i = 0; i < points.length; i++) {
      if (points[i] != other.points[i]) {
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
      rotation: next.rotation,
      origin: Offset.lerp(origin, next.origin, t) ?? next.origin,
      layout: next.layout,
      crop: next.crop,
      points: interpolatedPoints,
      thickness: thickness.lerpTo(next.thickness, t),
      areaGradient: Gradient.lerp(areaGradient, next.areaGradient, t),
      areaColor: Color.lerp(areaColor, next.areaColor, t),
      lineType: next.lineType,
      pointStyle: ILerpTo.lerp(pointStyle, next.pointStyle, t),
    );
  }
}
