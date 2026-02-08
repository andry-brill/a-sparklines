import 'package:flutter/material.dart';
import 'dart:ui' show lerpDouble;
import 'data_point.dart';
import '../interfaces.dart';
import '../renderers/line_chart_renderer.dart';

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
