part of 'data_point_pipeline.dart';


class _StackModifier implements DataPointModifier {

  final double offset;
  final double spacing;
  const _StackModifier({required this.spacing, required this.offset});

  @override
  List<DataPoint> apply(
      List<DataPoint> input,
      DataPointPipelineContext context,
      ) {
    final result = <DataPoint>[];

    for (final p in input) {

      final base = context.cumulativeByX[p.x] ?? offset;

      result.add(p.copyWith(
          y: base,
          dy: p.dy,
          fy: context.snap(base + p.dy)
      ));

      context.cumulativeByX[p.x] = context.snap(base + p.dy + spacing);
    }

    return result;
  }
}
