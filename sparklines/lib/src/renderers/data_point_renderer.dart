import 'dart:ui';

import 'package:sparklines/src/data/data_point.dart';
import 'package:sparklines/src/interfaces.dart';

abstract class ADataPointRenderer<ST extends IDataPointStyle> implements IDataPointRenderer {

  @override
  void render(
    ChartRenderContext context,
    Paint paint,
    IDataPointStyle style,
    DataPoint dataPoint,
  ) {
    renderStyle(paint, context, style as ST, dataPoint);
  }

  void renderStyle(Paint paint, ChartRenderContext context, ST style, DataPoint dataPoint);
}