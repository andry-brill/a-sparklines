

import 'dart:ui';

import '../../interfaces.dart';

class PieDataBuilder {

  final bool visible;

  final ChartRotation rotation;

  final Offset origin;

  final IChartLayout? layout;

  final bool? crop;

  final ThicknessData thickness;

  final double space;

  final ThicknessData? border;

  final double? borderRadius;

  const PieDataBuilder({
    required this.visible,
    required this.rotation,
    required this.origin,
    required this.layout,
    required this.crop,
    required this.thickness,
    required this.space,
    required this.border,
    required this.borderRadius
  });



}