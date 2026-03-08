part of 'data_point_pipeline.dart';


class _RescaleModifier implements DataPointModifier {

  /// Source bounds.
  /// If either bound is not finite, they are computed from input interval bounds.
  final double currentMin;
  final double currentMax;

  /// Target bounds.
  final double targetMin;
  final double targetMax;

  const _RescaleModifier({
    required this.currentMin,
    required this.currentMax,
    required this.targetMin,
    required this.targetMax,
  });

  @override
  List<DataPoint> apply(
      List<DataPoint> input,
      DataPointPipelineContext context,
      ) {
    if (input.isEmpty) return input;

    final curMin = currentMin.isFinite
        ? currentMin
        : context.rescaleMinY;
    final curMax = currentMax.isFinite
        ? currentMax
        : context.rescaleMaxY;

    assert(curMin != curMax, 'current min/max must differ');
    assert(targetMin != targetMax, 'target min/max must differ');

    final curSpan = curMax - curMin;
    final tgtSpan = targetMax - targetMin;

    double transform(double v) {
      final t = (v - curMin) / curSpan;
      return context.snap(targetMin + t * tgtSpan);
    }

    final result = <DataPoint>[];

    for (final p in input) {
      final newY = transform(p.y);
      final newFY = transform(p.fy);
      final newDY = context.snap(newFY - newY);

      result.add(
        p.copyWith(
          y: newY,
          dy: newDY,
          fy: newFY,
        ),
      );
    }

    return result;
  }
}
