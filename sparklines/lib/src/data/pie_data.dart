import 'package:flutter/material.dart';
import 'dart:ui' show lerpDouble;
import 'dart:math' as math;
import 'data_point.dart';
import 'pie_slice_layout.dart';
import '../interfaces.dart';
import '../renderers/pie_chart_renderer.dart';

/// Pie chart data.
///
/// Pies are treated like bars with a different axis: the main vector aligns
/// with the ray from (0,0) through each data point (x,y). [DataPoint.dy] is
/// the distance along that ray from (x,y) (radial extent). (x,y) must not be
/// (0,0) so the ray is defined. Origin is applied by the common renderer.
///
/// [thickness.size] = total sweep of the pie in radians (e.g. 2*pi for full circle).
/// [thickness.align]: 0 = (size/2) on each side of axis ray; !=0 splits left/right.
/// [space] is uniform linear gap between slices. Border and borderRadius like bars.
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
  final ThicknessData thickness;

  final double space;

  @override
  final ThicknessData? border;
  @override
  final double? borderRadius;

  /// Bounds from pie geometry: angles, dy along rays, and space offsets.
  Rect get _localBounds {
    final layout = computePieSliceLayout(
      points,
      space,
      thickness.size,
      thickness.align,
    );
    if (layout.isEmpty) return Rect.fromLTRB(0, 0, 1, 1);
    double minX = double.infinity, maxX = double.negativeInfinity;
    double minY = double.infinity, maxY = double.negativeInfinity;
    for (final s in layout) {
      sectorBounds(
        s.startAngle,
        s.endAngle,
        s.innerRadius,
        s.outerRadius,
        s.spaceOffset,
        (mnx, mxx, mny, mxy) {
          minX = math.min(minX, mnx);
          maxX = math.max(maxX, mxx);
          minY = math.min(minY, mny);
          maxY = math.max(maxY, mxy);
        },
      );
    }
    return Rect.fromLTRB(
      minX.isFinite ? minX : 0,
      minY.isFinite ? minY : 0,
      maxX.isFinite ? maxX : 1,
      maxY.isFinite ? maxY : 1,
    );
  }

  @override
  double get minX => _localBounds.left;

  @override
  double get maxX => _localBounds.right;

  @override
  double get minY => _localBounds.top;

  @override
  double get maxY => _localBounds.bottom;

  const PieData({
    this.visible = true,
    this.rotation = 0.0,
    this.origin = Offset.zero,
    this.layout,
    this.crop,
    required this.points,
    this.thickness = const ThicknessData(size: math.pi),
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
