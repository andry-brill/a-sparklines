part of 'data_point_pipeline.dart';


class _NormalizeModifier implements DataPointModifier {

  /// Sum of abs(dy) must be equal to total
  final double total;

  /// threshold in normalized units
  final double threshold;

  /// spacing in normalized units
  final double spacing;

  /// If true = adds one more spacing, useful in case of full pies
  final bool trailingSpacing;

  /// When set, removed (below-threshold) points' dy is accumulated here
  final DataPoint? thresholdPoint;

  _NormalizeModifier({
    required this.total,
    double? threshold,
    this.thresholdPoint,
    double? spacing,
    bool? trailingSpacing,
  }) :
        assert(total >= 0.0),
        assert(spacing == null || spacing >= 0.0),
        assert(threshold == null || threshold >= 0.0),
    spacing = spacing ?? 0.0,
    threshold = threshold ?? 0.0,
    trailingSpacing = trailingSpacing == true
  ;

  @override
  List<DataPoint> apply(
      List<DataPoint> input,
      DataPointPipelineContext context,
      ) {

    if (input.isEmpty) return input;

    var working = DataPoints.from(input);
    DataPoints removed = List.unmodifiable([]);
    final thresholdPoint = this.thresholdPoint;

    while (true) {

      DataPoints current = working;

      int? thresholdIndex;
      if (thresholdPoint != null && removed.isNotEmpty) {
        final sum = context.snap(removed.sumDY);
        if (sum != 0.0) {
          thresholdIndex = current.length;
          current = [...current, thresholdPoint.copyWith(
              dy: sum,
              data: { IThresholdPoints: ThresholdPoints(removed) }
          )];
        }
      }

      final normalized = _normalizeOnce(current, context);

      if (threshold <= 0.0) {
        return normalized;
      }

      if (working.isEmpty) {
        return normalized;
      }

      DataPoint? tPoint;
      bool canReturn = true;
      if (thresholdIndex != null) {
        tPoint = normalized.removeAt(thresholdIndex);
        canReturn = tPoint.dy.abs() >= threshold;
      }

      int? indexToRemove;
      double minValue = double.negativeInfinity;

      for (int i = 0; i < normalized.length; i++) {
        final v = normalized[i].dy.abs();
        if (indexToRemove == null || v < minValue) {
          minValue = v;
          indexToRemove = i;
        }
      }

      if ((minValue >= threshold) && canReturn) {
        if (tPoint == null) return normalized;
        return normalized..add(tPoint);
      }

      removed = List.unmodifiable([...removed, working.removeAt(indexToRemove!)]);
    }
  }

  List<DataPoint> _normalizeOnce(List<DataPoint> input, DataPointPipelineContext context) {

    double sum = 0.0;
    for (var p in input) {
      sum += p.dy.abs();
    }

    if (sum == 0) return input;

    double totalSpacing = spacing * (input.length - (trailingSpacing ? 0 : 1));
    double availableTotal = context.snap(max(0.0, total - totalSpacing));
    sum = context.snap(sum);

    final scale = availableTotal / sum;

    final result = <DataPoint>[];

    double newTotal = 0.0;
    for (final p in input) {
      final newDy = context.snap(p.dy * scale);
      result.add(p.copyWith(dy: newDy));
      newTotal += newDy;
    }

    newTotal = context.snap(newTotal);

    double diff = newTotal - availableTotal;
    if (diff != 0.0) {
      final last = result.removeLast();
      result.add(last.copyWith(dy: last.dy - diff));
    }

    return result;
  }

}
