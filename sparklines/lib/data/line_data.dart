import 'package:any_sparklines/interfaces/data_point_data.dart';
import 'package:flutter/material.dart';
import '../interfaces/chart_flip.dart';
import '../interfaces/chart_rotation.dart';
import '../interfaces/chart_area.dart';
import '../interfaces/layout.dart';
import '../interfaces/line_type.dart';
import '../interfaces/sparklines_data.dart';
import '../interfaces/thickness.dart';
import '../interfaces/data_point_style.dart';
import '../interfaces/lerp.dart';
import '../renderers/line_chart_renderer.dart';
import '../renderers/lines/curved_line_renderer.dart';
import '../renderers/lines/linear_line_renderer.dart';
import '../renderers/lines/stepped_line_renderer.dart';
import 'data_point.dart';


class LineData implements ISparklinesData, IChartThickness, IChartDataPointStyle, IChartArea, ILineChartData {

  static final LineChartRenderer defaultRenderer = LineChartRenderer();

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
  LineChartRenderer get renderer => defaultRenderer;

  final List<DataPoint> line;

  @override
  double get minX => line.minX;

  @override
  double get maxX => line.maxX;

  @override
  double get minY => line.minY;

  @override
  double get maxY => line.maxY;

  @override
  final ThicknessData thickness;

  @override
  final Gradient? areaGradient;

  @override
  final Color? areaColor;

  @override
  final PathFillType? areaFillType;

  final ILineTypeData lineType;

  @override
  final IDataPointStyle? pointStyle;

  const LineData({
    this.visible = true,
    this.rotation = ChartRotation.d0,
    this.flip = ChartFlip.none,
    this.origin = Offset.zero,
    this.layout,
    this.crop,
    required this.line,
    this.thickness = const ThicknessData(size: 2.0),
    this.areaGradient,
    this.areaColor,
    this.lineType = const LinearLineData(),
    this.pointStyle,
    this.areaFillType,
  });

  LineData copyWith({
    bool? visible,
    ChartRotation? rotation,
    ChartFlip? flip,
    Offset? origin,
    IChartLayout? layout,
    bool? crop,
    List<DataPoint>? line,
    ThicknessData? thickness,
    Gradient? areaGradient,
    Color? areaColor,
    PathFillType? areaFillType,
    ILineTypeData? lineType,
    IDataPointStyle? pointStyle,
  }) {
    return LineData(
      visible: visible ?? this.visible,
      rotation: rotation ?? this.rotation,
      flip: flip ?? this.flip,
      origin: origin ?? this.origin,
      layout: layout ?? this.layout,
      crop: crop ?? this.crop,
      line: line ?? this.line,
      thickness: thickness ?? this.thickness,
      areaGradient: areaGradient ?? this.areaGradient,
      areaColor: areaColor ?? this.areaColor,
      areaFillType: areaFillType ?? this.areaFillType,
      lineType: lineType ?? this.lineType,
      pointStyle: pointStyle ?? this.pointStyle,
    );
  }

  @override
  bool shouldRepaint(ISparklinesData other) {
    if (other is! LineData) return true;
    if (visible != other.visible) return true;
    if (rotation != other.rotation) return true;
    if (flip != other.flip) return true;
    if (origin != other.origin) return true;
    if (layout != other.layout) return true;
    if (line.length != other.line.length) return true;
    if (thickness != other.thickness) return true;
    if (areaGradient != other.areaGradient) return true;
    if (areaColor != other.areaColor) return true;
    if (areaFillType != other.areaFillType) return true;
    if (lineType != other.lineType) return true;
    if (pointStyle != other.pointStyle) return true;

    for (int i = 0; i < line.length; i++) {
      if (line[i] != other.line[i]) {
        return true;
      }
    }

    return false;
  }

  @override
  ISparklinesData lerpTo(ISparklinesData next, double t) {
    if (next is! LineData) return next;
    if (line.length != next.line.length) return next;
    if (visible != next.visible) return next;

    final interpolatedPoints = <DataPoint>[];
    for (int i = 0; i < line.length; i++) {
      interpolatedPoints.add(line[i].lerpTo(next.line[i], t));
    }

    return LineData(
      visible: next.visible,
      rotation: next.rotation,
      flip: next.flip,
      origin: Offset.lerp(origin, next.origin, t) ?? next.origin,
      layout: next.layout,
      crop: next.crop,
      line: interpolatedPoints,
      thickness: thickness.lerpTo(next.thickness, t),
      areaGradient: Gradient.lerp(areaGradient, next.areaGradient, t),
      areaColor: Color.lerp(areaColor, next.areaColor, t),
      areaFillType: next.areaFillType,
      lineType: next.lineType,
      pointStyle: ILerpTo.lerp<IDataPointData>(pointStyle, next.pointStyle, t) as IDataPointStyle?,
    );
  }
}


class LinearLineData implements ILineTypeData {

  @override
  final bool isStrokeCapRound;
  @override
  final bool isStrokeJoinRound;

  static const LinearLineRenderer _renderer = LinearLineRenderer();

  const LinearLineData({this.isStrokeCapRound = false, this.isStrokeJoinRound = false});

  @override
  ILineTypeRenderer get renderer => _renderer;
}

class SteppedLineData implements ILineTypeData {

  /// 0.0 → previous point, 1.0 → next point
  final double stepJumpAt;

  @override
  final bool isStrokeCapRound;
  @override
  final bool isStrokeJoinRound;

  static const SteppedLineRenderer _renderer = SteppedLineRenderer();

  const SteppedLineData({this.stepJumpAt = 0.5, this.isStrokeCapRound = false, this.isStrokeJoinRound = false});
  const SteppedLineData.start({this.isStrokeCapRound = false, this.isStrokeJoinRound = false}) : stepJumpAt = 0.0;
  const SteppedLineData.middle({this.isStrokeCapRound = false, this.isStrokeJoinRound = false}) : stepJumpAt = 0.5;
  const SteppedLineData.end({this.isStrokeCapRound = false, this.isStrokeJoinRound = false}) : stepJumpAt = 1.0;

  @override
  ILineTypeRenderer get renderer => _renderer;
}

class CurvedLineData implements ILineTypeData {

  /// Curve smoothness (0.0 to 1.0)
  final double smoothness;

  @override
  final bool isStrokeCapRound;
  @override
  final bool isStrokeJoinRound;

  static const CurvedLineRenderer _renderer = CurvedLineRenderer();

  const CurvedLineData({this.smoothness = 0.35, this.isStrokeCapRound = false, this.isStrokeJoinRound = false});

  @override
  ILineTypeRenderer get renderer => _renderer;

}
