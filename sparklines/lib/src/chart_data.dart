import 'package:flutter/material.dart';
import 'data_point.dart';
import 'interfaces.dart';
import 'stroke_align.dart';

/// Bar chart data
class BarData implements ISparklinesData {
  @override
  final bool visible;
  @override
  final double rotation;
  @override
  final Offset origin;

  final List<DataPoint> bars;
  final bool stacked;
  final double width;
  final Color? color;
  final Gradient? gradient;
  final BorderSide? border;
  final BorderRadius? borderRadius;
  final Color? borderColor;

  const BarData({
    this.visible = true,
    this.rotation = 0.0,
    this.origin = Offset.zero,
    required this.bars,
    this.stacked = false,
    required this.width,
    this.color,
    this.gradient,
    this.border,
    this.borderRadius,
    this.borderColor,
  });
}

/// Line chart data
class LineData implements ISparklinesData {
  @override
  final bool visible;
  @override
  final double rotation;
  @override
  final Offset origin;

  final List<DataPoint> points;
  final Color? color;
  final double width;
  final Gradient? gradient;
  final Gradient? gradientArea;
  final ILineTypeData? lineType;
  final bool isStrokeCapRound;
  final bool isStrokeJoinRound;
  final IDataPointStyle? pointStyle;

  const LineData({
    this.visible = true,
    this.rotation = 0.0,
    this.origin = Offset.zero,
    required this.points,
    this.color,
    this.width = 2.0,
    this.gradient,
    this.gradientArea,
    this.lineType,
    this.isStrokeCapRound = false,
    this.isStrokeJoinRound = false,
    this.pointStyle,
  });
}

/// Between line chart data (fills area between two lines)
class BetweenLineData implements ISparklinesData {
  @override
  final bool visible;
  @override
  final double rotation;
  @override
  final Offset origin;

  final LineData from;
  final LineData to;
  final Color? color;
  final Gradient? gradient;

  const BetweenLineData({
    this.visible = true,
    this.rotation = 0.0,
    this.origin = Offset.zero,
    required this.from,
    required this.to,
    this.color,
    this.gradient,
  });
}

/// Pie chart data
class PieData implements ISparklinesData {
  @override
  final bool visible;
  @override
  final double rotation;
  @override
  final Offset origin;

  final List<DataPoint> pies;
  final double stroke;
  final StrokeAlign strokeAlign;
  final Color? color;
  final Gradient? gradient;
  final double space;
  final BorderSide? border;
  final BorderRadius? borderRadius;
  final Color? borderColor;

  const PieData({
    this.visible = true,
    this.rotation = 0.0,
    this.origin = Offset.zero,
    required this.pies,
    this.stroke = double.infinity,
    this.strokeAlign = StrokeAlign.center,
    this.color,
    this.gradient,
    this.space = 0.0,
    this.border,
    this.borderRadius,
    this.borderColor,
  });
}
