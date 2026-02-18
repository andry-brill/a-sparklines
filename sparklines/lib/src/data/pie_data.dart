import 'package:flutter/material.dart';
import 'dart:ui' show lerpDouble;
import 'data_point.dart';
import 'pie_slice_data.dart';
import '../interfaces.dart';
import '../renderers/pie_chart_renderer.dart';


class PieData implements ISparklinesData, IChartThickness, IChartBorder, IChartDataPointStyle {
  static final IChartRenderer defaultRenderer = PieChartRenderer();

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

  /// Each point (x,y) defines arc, where radius = x, startAngle = y, endAngle = y + dy
  final List<DataPoint> points;

  @override
  final ThicknessData thickness;

  final double space;

  @override
  final ThicknessData? border;

  @override
  final double? borderRadius;

  Rect? _bounds;

  Rect get bounds {

    if (_bounds != null) return _bounds!;

    final layouts = computePies(
      points,
      space,
      thickness,
      borderRadius ?? 0.0,
      null
    );

    if (layouts.isEmpty) return _bounds = Rect.fromLTRB(0, 0, 1, 1);
    if (layouts.length == 1) return _bounds = layouts.first.toPath().getBounds();

    for (var layout in layouts) {
      if (_bounds == null) {
        _bounds = layout.toPath().getBounds();
      } else {
        _bounds = _bounds!.expandToInclude(layout.toPath().getBounds());
      }
    }

    return _bounds!;
  }

  @override
  double get minX => bounds.left;

  @override
  double get maxX => bounds.right;

  @override
  double get minY => bounds.top;

  @override
  double get maxY => bounds.bottom;

  @override
  final IDataPointStyle? pointStyle;

  final String? debug;

  PieData({
    this.visible = true,
    this.rotation = ChartRotation.d0,
    this.origin = Offset.zero,
    this.layout,
    this.crop,
    required this.points,
    this.thickness = const ThicknessData(size: 2.0),
    this.space = 0.0,
    this.border,
    this.borderRadius,
    this.pointStyle,
    this.debug
  });

  PieData copyWith({
    bool? visible,
    ChartRotation? rotation,
    Offset? origin,
    IChartLayout? layout,
    bool? crop,
    List<DataPoint>? points,
    ThicknessData? thickness,
    double? space,
    ThicknessData? border,
    double? borderRadius,
    String? debug,
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
      debug: debug ?? this.debug
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
      rotation: next.rotation,
      origin: Offset.lerp(origin, next.origin, t) ?? next.origin,
      layout: next.layout,
      crop: next.crop,
      points: interpolatedPies,
      thickness: thickness.lerpTo(next.thickness, t),
      space: lerpDouble(space, next.space, t) ?? next.space,
      border: ILerpTo.lerp(border, next.border, t),
      borderRadius: lerpDouble(borderRadius, next.borderRadius, t) ?? next.borderRadius,
      debug: next.debug
    );
  }

}
