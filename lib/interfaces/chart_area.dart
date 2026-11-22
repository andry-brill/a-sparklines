import 'package:flutter/painting.dart';

abstract class IChartArea {
  Gradient? get areaGradient;
  Color? get areaColor;
  PathFillType? get areaFillType;
}

