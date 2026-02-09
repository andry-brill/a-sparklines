
import 'dart:ui';

import 'package:sparklines/src/layout/coordinate_transformer.dart';
import 'package:sparklines/src/data/data_point.dart';
import 'package:sparklines/src/interfaces.dart';

abstract class ADataPointRenderer<ST extends IDataPointStyle> implements IDataPointRenderer {

  @override
  void render(Canvas canvas,
      Paint paint,
      CoordinateTransformer transformer,
      IDataPointStyle style,
      DataPoint dataPoint
      ) {
    renderStyle(canvas, paint, transformer, style as ST, dataPoint);
  }

  void renderStyle(Canvas canvas, Paint paint, CoordinateTransformer transformer, ST style, DataPoint dataPoint);

}