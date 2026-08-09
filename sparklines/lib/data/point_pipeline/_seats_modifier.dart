part of 'data_point_pipeline.dart';


class _SeatsModifier implements DataPointModifier {

  final SeatSelector? selector;
  final SeatPredicate? predicate;
  final Set<SeatKey>? keys;
  final IDataPointStyle style;
  final IDataPointExtent? extent;

  const _SeatsModifier({
    required this.selector,
    required this.predicate,
    required this.keys,
    required this.style,
    required this.extent,
  });

  bool _matches(DataPoint point, SeatKey key) {
    if (keys != null && !keys!.contains(key)) return false;
    if (selector != null && !selector!.matches(key)) return false;
    if (predicate != null && !predicate!(point, key)) return false;
    return true;
  }

  @override
  List<DataPoint> apply(
      List<DataPoint> input,
      DataPointPipelineContext context,
      ) {
    return input.map((point) {
      final key = point.key;
      if (key is! SeatKey || !_matches(point, key)) return point;
      return point.copyWith(data: {
        IDataPointStyle: style,
        if (extent != null) IDataPointExtent: extent,
      });
    }).toList(growable: false);
  }

}
