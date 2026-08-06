part of 'data_point_pipeline.dart';


class _StackModifier implements DataPointModifier {

  final double offset;
  final double spacing;
  final double? groupingStep;
  const _StackModifier({
    required this.spacing,
    required this.offset,
    required this.groupingStep,
  });

  @override
  List<DataPoint> apply(
      List<DataPoint> input,
      DataPointPipelineContext context,
      ) {
    final result = <DataPoint>[];

    for (final p in input) {

      final groupKey = groupingStep == null
          ? p.x
          : (p.x / groupingStep!).roundToDouble();
      final base = context.cumulativeByX[groupKey] ?? offset;

      result.add(p.copyWith(
          y: base,
          dy: p.dy,
          fy: context.snap(base + p.dy)
      ));

      context.cumulativeByX[groupKey] = context.snap(base + p.dy + spacing);
    }

    return result;
  }
}
