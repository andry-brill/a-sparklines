

import '../data/data_point.dart';
import 'lerp.dart';

typedef DataPointDataMap = Map<Type, IDataPointData?>;

abstract class IDataPointData implements ILerpTo<IDataPointData> {}

abstract class ADataPointData<E> implements IDataPointData {

  const ADataPointData();

  @override
  IDataPointData lerpTo(IDataPointData next, double t) {
    if (next is! E) return next;
    return lerp(next as E, t) as IDataPointData;
  }

  E lerp(E next, double t);

}

class ADataPointPlainData<E> extends ADataPointData<E> {

  const ADataPointPlainData();

  @override
  E lerp(E next, double t) {
    if (t <= 0.0) return (this as E);
    return next;
  }
}

extension DataPointDataMapExtension on DataPointDataMap {

  DataPointDataMap copyWith(DataPointDataMap other) => {...this, ...other};

  DataPointDataMap lerpTo(DataPointDataMap nextMap, double t) {

    if (isEmpty || nextMap.isEmpty) return nextMap;

    DataPointDataMap result = {};
    for (var entry in nextMap.entries) {
      final previous = this[entry.key];
      final next = entry.value;
      result[entry.key] = previous != null && next != null ? previous.lerpTo(next, t) : next;
    }

    return result;
  }

}


class DataPointKey {

  final int? id;
  final String? key;
  final String? label;

  const DataPointKey({this.id, this.key, this.label});

  @override
  bool operator ==(Object other) => identical(this, other) || other is DataPointKey && id == other.id && key == other.key && label == other.label;

  @override
  int get hashCode => Object.hash(id, key, label);

}

abstract class IThresholdPoints {
  DataPoints get thresholdPoints;
}

class ThresholdPoints extends ADataPointPlainData<ThresholdPoints> implements IThresholdPoints {

  @override final DataPoints thresholdPoints;

  const ThresholdPoints(this.thresholdPoints);

}
