part of 'data_point_pipeline.dart';


class _ScatterZModifier implements DataPointModifier {

  final bool Function(DataPoint point)? predicate;
  final Set<Object>? keys;
  final StylesInterval style;
  final ExtentsInterval? extent;

  const _ScatterZModifier({
    required this.predicate,
    required this.keys,
    required this.style,
    required this.extent,
  });

  bool _matches(DataPoint point) {
    if (keys != null && !keys!.contains(point.key)) return false;
    if (predicate != null && !predicate!(point)) return false;
    return true;
  }

  IDataPointStyle _style(double t) {
    if (identical(style.min, style.max)) return style.min;
    if (t <= 0.0) return style.min;
    if (t >= 1.0) return style.max;
    return style.min.lerpTo(style.max, t) as IDataPointStyle;
  }

  ChartInsets _extent(ExtentsInterval interval, double t) {
    return ChartInsets(
      left: ILengthValue.lerp(interval.min.left, interval.max.left, t),
      top: ILengthValue.lerp(interval.min.top, interval.max.top, t),
      right: ILengthValue.lerp(interval.min.right, interval.max.right, t),
      bottom: ILengthValue.lerp(interval.min.bottom, interval.max.bottom, t),
    );
  }

  @override
  List<DataPoint> apply(
      List<DataPoint> input,
      DataPointPipelineContext context,
      ) {
    return input.map((point) {
      if (!_matches(point)) return point;
      if (!point.z.isFinite) {
        throw ArgumentError.value(point.z, 'DataPoint.z', 'must be finite');
      }
      final t = point.z.clamp(0.0, 1.0).toDouble();
      final pointExtent = extent;
      return point.copyWith(data: {
        IDataPointStyle: _style(t),
        if (pointExtent != null) IDataPointExtent: _extent(pointExtent, t),
      });
    }).toList(growable: false);
  }
}
