import 'dart:ui';

import 'data_point_data.dart';
import 'thickness.dart';


abstract class IChartBorder {
  ThicknessData? get border;
  double? get borderRadius;
}

abstract class IDataPointBorder implements IChartBorder {
}

class DataPointBorder extends ADataPointData<DataPointBorder> implements IDataPointBorder {

  @override
  final ThicknessData? border;
  @override
  final double? borderRadius;

  const DataPointBorder({this.borderRadius, this.border});

  @override
  DataPointBorder lerp(DataPointBorder next, double t) {
    return DataPointBorder(
      border: border != null && next.border != null ? border!.lerpTo(next.border!, t) : next.border,
      borderRadius: lerpDouble(borderRadius, next.borderRadius, t)
    );
  }
}