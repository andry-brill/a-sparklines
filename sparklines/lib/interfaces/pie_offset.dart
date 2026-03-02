

import 'dart:ui';

import 'data_point_data.dart';


abstract class IChartPieOffset {
  double? get pieOffset;
}

abstract class IPieOffset implements IChartPieOffset {
}

class PieOffset extends ADataPointData<PieOffset> implements IPieOffset {

  @override
  final double? pieOffset;

  const PieOffset(this.pieOffset);

  @override
  PieOffset lerp(PieOffset next, double t) {
    return PieOffset(lerpDouble(pieOffset, next.pieOffset, t));
  }
}