import 'package:any_sparklines/interfaces/pie_offset.dart';
import 'package:flutter/material.dart';
import 'dart:ui' show lerpDouble;
import '../interfaces/chart_rotation.dart';
import '../interfaces/chart_style.dart';
import '../interfaces/data_point_style.dart';
import '../interfaces/layout.dart';
import '../interfaces/lerp.dart';
import '../interfaces/sparklines_data.dart';
import '../interfaces/thickness.dart';
import '../renderers/pie_chart_renderer.dart';
import 'data_point.dart';
import 'pie_slice_data.dart';


class PieData implements ISparklinesData, IChartThickness, IChartBorder, IChartDataPointStyle, IChartPieOffset {
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

  @override
  final double pieOffset;

  final double padAngle;

  @override
  final ThicknessData? border;

  @override
  final double? borderRadius;

  Rect? _bounds;

  Rect get bounds {

    if (_bounds != null) return _bounds!;

    final layouts = computePies(
      points,
      pieOffset,
      padAngle,
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

  PieData({
    this.visible = true,
    this.rotation = ChartRotation.d0,
    this.origin = Offset.zero,
    this.layout,
    this.crop,
    required this.points,
    this.thickness = const ThicknessData(size: 2.0),
    this.pieOffset = 0.0,
    this.padAngle = 0.0,
    this.border,
    this.borderRadius,
    this.pointStyle,
  });

  PieData copyWith({
    bool? visible,
    ChartRotation? rotation,
    Offset? origin,
    IChartLayout? layout,
    bool? crop,
    List<DataPoint>? points,
    ThicknessData? thickness,
    double? pieOffset,
    double? padAngle,
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
      pieOffset: pieOffset ?? this.pieOffset,
      padAngle: padAngle ?? this.padAngle,
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
    if (pieOffset != other.pieOffset) return true;
    if (padAngle != other.padAngle) return true;
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
      pieOffset: lerpDouble(pieOffset, next.pieOffset, t) ?? next.pieOffset,
      padAngle: lerpDouble(padAngle, next.padAngle, t) ?? next.padAngle,
      border: ILerpTo.lerp(border, next.border, t),
      borderRadius: lerpDouble(borderRadius, next.borderRadius, t) ?? next.borderRadius,
    );
  }

}
