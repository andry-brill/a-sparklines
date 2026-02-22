import 'dart:ui';

import 'package:sparklines/src/data/data_point.dart';
import 'package:sparklines/src/interfaces.dart';

abstract class ADataPointRenderer<ST extends IDataPointStyle> implements IDataPointRenderer {

  @override
  void render(
    Canvas canvas,
    ChartTransform transform,
    Paint paint,
    IDataPointStyle style,
    DataPoint dataPoint,
  ) {
    renderStyle(canvas, paint, transform, style as ST, dataPoint);
  }

  void renderStyle(Canvas canvas, Paint paint, ChartTransform transform, ST style, DataPoint dataPoint);
}