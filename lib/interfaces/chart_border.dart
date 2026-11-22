import 'data_point_data.dart';
import 'length_value.dart';
import 'thickness.dart';


abstract class IChartBorder {
  ThicknessData? get border;
  ILengthValue? get borderRadius;
}

abstract class IDataPointBorder implements IChartBorder {
}

class DataPointBorder extends ADataPointData<DataPointBorder> implements IDataPointBorder {

  @override
  final ThicknessData? border;
  @override
  final ILengthValue? borderRadius;

  const DataPointBorder({this.borderRadius, this.border});

  @override
  DataPointBorder lerp(DataPointBorder next, double t) {
    return DataPointBorder(
      border: border != null && next.border != null ? border!.lerpTo(next.border!, t) : next.border,
      borderRadius: ILengthValue.lerp(borderRadius, next.borderRadius, t)
    );
  }
}
