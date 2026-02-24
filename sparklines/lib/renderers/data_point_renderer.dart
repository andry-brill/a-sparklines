import 'dart:ui';

import '../data/data_point.dart';
import '../interfaces/chart_transform.dart';
import '../interfaces/data_point_style.dart';

abstract class ADataPointRenderer<ST extends IDataPointStyle> implements IDataPointRenderer {

  @override
  void render(
    Canvas canvas,
    ChartTransform transform,
    Paint paint,
    IDataPointStyle style,
    Object dataPoint,
  ) {
    renderStyle(canvas, paint, transform, style as ST, dataPoint as DataPoint);
  }

  void renderStyle(Canvas canvas, Paint paint, ChartTransform transform, ST style, DataPoint dataPoint);
}