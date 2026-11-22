import 'package:flutter/foundation.dart';

import 'data_point_data.dart';
import 'length_value.dart';

abstract interface class IDataPointExtent implements IDataPointData {
  ILengthValue? get left;
  ILengthValue? get top;
  ILengthValue? get right;
  ILengthValue? get bottom;
}

/// Screen-space insets applied inside the chart viewport or around a data point.
@immutable
class ChartInsets extends ADataPointData<ChartInsets> implements IDataPointExtent {

  @override final ILengthValue? left;
  @override final ILengthValue? top;
  @override final ILengthValue? right;
  @override final ILengthValue? bottom;

  const ChartInsets({
    this.left,
    this.top,
    this.right,
    this.bottom,
  });

  const ChartInsets.all(ILengthValue value) :
    left = value,
    top = value,
    right = value,
    bottom = value;

  const ChartInsets.horizontal(ILengthValue value) :
    left = value,
    top = null,
    right = value,
    bottom = null;

  const ChartInsets.vertical(ILengthValue value) :
    left = null,
    top = value,
    right = null,
    bottom = value;

  bool get isEmpty => left == null && top == null && right == null && bottom == null;

  @override
  ChartInsets lerp(ChartInsets next, double t) {
    return ChartInsets(
      left: ILengthValue.lerp(left, next.left, t),
      top: ILengthValue.lerp(top, next.top, t),
      right: ILengthValue.lerp(right, next.right, t),
      bottom: ILengthValue.lerp(bottom, next.bottom, t),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ChartInsets &&
      left == other.left &&
      top == other.top &&
      right == other.right &&
      bottom == other.bottom;
  }

  @override
  int get hashCode => Object.hash(left, top, right, bottom);

}
