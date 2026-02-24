import 'package:flutter/material.dart';

import 'data_point_style.dart';
import 'thickness.dart';

abstract class IChartArea {
  Gradient? get areaGradient;
  Color? get areaColor;
  PathFillType? get areaFillType;
}

abstract class IChartDataPointStyle {
  IDataPointStyle? get pointStyle;
}

abstract class IChartBorder {
  ThicknessData? get border;
  double? get borderRadius;
}
