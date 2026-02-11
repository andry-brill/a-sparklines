import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'line_data.dart';
import '../interfaces.dart';
import '../renderers/between_line_renderer.dart';

/// Between line chart data (fills area between two lines)
class BetweenLineData implements ISparklinesData {
  static final IChartRenderer defaultRenderer = BetweenLineRenderer();

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

  final Color areaColor;
  final Gradient? areaGradient;

  const BetweenLineData({
    this.visible = true,
    this.rotation = ChartRotation.d0,
    this.origin = Offset.zero,
    this.layout,
    this.crop,
    required this.from,
    required this.to,
    this.areaColor = const Color(0xFF000000),
    this.areaGradient,
  });

  BetweenLineData copyWith({
    bool? visible,
    ChartRotation? rotation,
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
      areaColor: color ?? this.areaColor,
      areaGradient: gradient ?? this.areaGradient,
    );
  }

  @override
  bool shouldRepaint(ISparklinesData other) {
    if (other is! BetweenLineData) return true;
    if (visible != other.visible) return true;
    if (rotation != other.rotation) return true;
    if (origin != other.origin) return true;
    if (layout != other.layout) return true;
    if (areaColor != other.areaColor) return true;
    if (areaGradient != other.areaGradient) return true;

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
      rotation: next.rotation,
      origin: Offset.lerp(origin, next.origin, t) ?? next.origin,
      layout: next.layout,
      crop: next.crop,
      from: from.lerpTo(next.from, t) as LineData,
      to: to.lerpTo(next.to, t) as LineData,
      areaColor: Color.lerp(areaColor, next.areaColor, t)!,
      areaGradient: Gradient.lerp(areaGradient, next.areaGradient, t),
    );
  }
}
