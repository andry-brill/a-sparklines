import 'package:flutter/material.dart';

import '../data/data_point.dart';
import 'chart_transform.dart';
import 'thickness.dart';

/// Data interface for line-type rendering (implemented by [LineData] in data/line_data.dart).
abstract class ILineChartData {
  List<DataPoint> get line;
  ThicknessData get thickness;
  ILineTypeData get lineType;
}

/// Interface for line type renderers (path building + stroke rendering)
abstract class ILineTypeRenderer {
  Path toPath(ILineTypeData lineType, List<DataPoint> points,
      {bool reverse = false, Path? path});
  void render(Canvas canvas, ChartTransform transform, ILineChartData lineData);
}

/// Marker interface for line type data
abstract class ILineTypeData {
  bool get isStrokeCapRound;
  bool get isStrokeJoinRound;
  ILineTypeRenderer get renderer;
}
