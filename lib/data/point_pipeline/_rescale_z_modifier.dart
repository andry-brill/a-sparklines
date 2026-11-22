part of 'data_point_pipeline.dart';


class _RescaleZModifier implements DataPointModifier {

  final double currentMin;
  final double currentMax;
  final double targetMin;
  final double targetMax;
  final bool clamp;

  const _RescaleZModifier({
    required this.currentMin,
    required this.currentMax,
    required this.targetMin,
    required this.targetMax,
    required this.clamp,
  });

  @override
  List<DataPoint> apply(
      List<DataPoint> input,
      DataPointPipelineContext context,
      ) {
    if (input.isEmpty) return input;

    final curMin = currentMin.isFinite ? currentMin : context.rescaleMinZ;
    final curMax = currentMax.isFinite ? currentMax : context.rescaleMaxZ;

    if (curMin > curMax) {
      throw StateError('resolved currentMin must be less than or equal to currentMax');
    }

    if (curMin == curMax) {
      final midpoint = context.snap(targetMin + (targetMax - targetMin) / 2.0);
      return List.unmodifiable(input.map((p) {
        if (!p.z.isFinite) {
          throw ArgumentError.value(p.z, 'DataPoint.z', 'must be finite');
        }
        return p.copyWith(z: midpoint);
      }));
    }

    final curSpan = curMax - curMin;
    final targetSpan = targetMax - targetMin;

    return List.unmodifiable(input.map((p) {
      if (!p.z.isFinite) {
        throw ArgumentError.value(p.z, 'DataPoint.z', 'must be finite');
      }
      var t = (p.z - curMin) / curSpan;
      if (clamp) t = t.clamp(0.0, 1.0).toDouble();
      return p.copyWith(z: context.snap(targetMin + t * targetSpan));
    }));
  }
}
