import 'package:flutter/material.dart';

abstract class IChartArea {
  Gradient? get areaGradient;
  Color? get areaColor;
  PathFillType? get areaFillType;
}

