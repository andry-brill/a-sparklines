import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';

import 'data_point_data.dart';
import 'lerp.dart';

abstract class IThicknessOverride {
  double? get size;
  Gradient? get gradient;
  double? get align;
  Color? get color;
}

class ThicknessOverride extends ADataPointData<ThicknessOverride> implements IThicknessOverride {

  @override final double? size;
  @override final Gradient? gradient;
  @override final double? align;
  @override final Color? color;

  const ThicknessOverride({
    this.size,
    this.gradient,
    this.align,
    this.color,
  });

  @override
  ThicknessOverride lerp(ThicknessOverride next, double t) {
    return ThicknessOverride(
      size: lerpDouble(size, next.size, t),
      align: lerpDouble(align, next.align, t),
      color: Color.lerp(color, next.color, t),
      gradient: Gradient.lerp(gradient, next.gradient, t),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ThicknessOverride) return false;
    return size == other.size &&
        color == other.color &&
        gradient == other.gradient &&
        align == other.align;
  }
}

class ThicknessData implements ILerpTo<ThicknessData> {

  final double size;

  /// Gradient has higher priority if set then color
  final Gradient? gradient;

  final Color color;

  final double align;

  const ThicknessData({
    required this.size,
    this.color = const Color(0xFF000000),
    this.gradient,
    this.align = alignCenter,
  });

  static const double alignInside = -1.0;
  static const double alignCenter = 0.0;
  static const double alignOutside = 1.0;

  @override
  ThicknessData lerpTo(ThicknessData next, double t) {
    return ThicknessData(
      size: lerpDouble(size, next.size, t) ?? next.size,
      color: Color.lerp(color, next.color, t) ?? next.color,
      gradient: Gradient.lerp(gradient, next.gradient, t) ?? next.gradient,
      align: lerpDouble(align, next.align, t) ?? next.align,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ThicknessData) return false;
    return size == other.size &&
        color == other.color &&
        gradient == other.gradient &&
        align == other.align;
  }
}

abstract class IChartThickness {
  ThicknessData get thickness;
}
