part of 'data_point_pipeline.dart';


class _AggregationModifier implements DataPointModifier {

  final DataAggregation function;
  final int? window;

  const _AggregationModifier({required this.function, this.window});

  @override
  List<DataPoint> apply(
      List<DataPoint> input,
      DataPointPipelineContext context,
      ) {
    if (input.isEmpty) return input;

    final result = <DataPoint>[];

    for (int i = 0; i < input.length; i++) {
      final start = window == null ? 0 : max(0, i - window! + 1);
      final slice = input.sublist(start, i + 1);
      final values = slice.map((p) => p.dy).toList();

      final aggregated = _aggregate(values, context);
      final p = input[i];
      result.add(p.copyWith(
        dy: aggregated,
        fy: p.y + aggregated,
      ));
    }

    return result;
  }

  double _aggregate(List<double> values, DataPointPipelineContext context) {
    if (values.isEmpty) return 0.0;

    switch (function) {
      case DataAggregation.sum:
        return context.snap(values.reduce((a, b) => a + b));
      case DataAggregation.avg:
        return context.snap(
            values.reduce((a, b) => a + b) / values.length);
      case DataAggregation.min:
        return context.snap(values.reduce(min));
      case DataAggregation.max:
        return context.snap(values.reduce(max));
      case DataAggregation.median:
        final sorted = List<double>.from(values)..sort();
        final n = sorted.length;
        if (n.isOdd) {
          return context.snap(sorted[n ~/ 2]);
        }
        final mid = n ~/ 2;
        return context.snap((sorted[mid - 1] + sorted[mid]) / 2.0);
      case DataAggregation.std:
        if (values.length < 2) return 0.0;
        final mean = values.reduce((a, b) => a + b) / values.length;
        final variance = values
            .map((v) => (v - mean) * (v - mean))
            .reduce((a, b) => a + b) /
            (values.length - 1);
        return context.snap(sqrt(variance));
    }
  }
}
