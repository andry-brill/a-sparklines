import 'dart:collection';
import 'dart:math';

import 'package:any_sparklines/interfaces/data_point_data.dart';

import 'data_point.dart';


class _LazyList<T> extends ListBase<T> {

  final List<T> Function() _getter;

  _LazyList(this._getter);

  List<T>? _cache;

  List<T> get _list => _cache ??= List.unmodifiable(_getter());

  @override
  int get length => _list.length;

  @override
  set length(int newLength) =>
      throw UnsupportedError('LazyList is read-only');

  @override
  T operator [](int index) => _list[index];

  @override
  void operator []=(int index, T value) =>
      throw UnsupportedError('LazyList is read-only');

}

abstract class DataPointModifier {

  List<DataPoint> apply(
      List<DataPoint> input,
      DataPointPipelineContext context,
      );
}


class DataPointPipelineContext {


  final double _snapEpsilon;
  final int _snapMultiplier;
  DataPointPipelineContext(this._snapEpsilon, this._snapMultiplier);

  final cumulativeByX = <double, double>{};

  double globalMinY = double.infinity;
  double globalMaxY = double.negativeInfinity;

  void updateBounds(Iterable<DataPoint> points) {
    globalMinY = min(globalMinY, points.minY);
    globalMaxY = max(globalMaxY, points.maxY);
  }


  double snap(double v) {
    if (v.abs() < _snapEpsilon) return 0.0;
    final nv = v * _snapMultiplier;
    final r = nv.roundToDouble();
    if ((nv - r).abs() < _snapEpsilon) return r / _snapMultiplier;
    return v;
  }
}


class DataPointPipeline {

  final DataPointPipelineContext context;

  DataPointPipeline({
    double snapEpsilon = 1e-9,
    int snapMultiplier = 1000000
  }) : context = DataPointPipelineContext(snapEpsilon, snapMultiplier);

  final List<List<DataPoint>> _inputs = [];

  List<List<DataPoint>>? _outputs;

  final List<DataPointModifier> _modifiers = [];

  bool _computed = false;

  int _register(List<DataPoint> input) {
    _inputs.add(input);
    return _inputs.length - 1;
  }

  List<DataPoint> build(List<DataPoint> input) {

    final id = _register(input);

    return _LazyList(() {

      _computeIfNeeded();

      return _outputs![id];

    });
  }

  void _computeIfNeeded() {

    if (_computed) return;

    final outputs = <List<DataPoint>>[];

    for (final input in _inputs) {

      var result = input;

      for (final modifier in _modifiers) {
        result = modifier.apply(result, context);
      }

      outputs.add(List.unmodifiable(result));
    }

    _outputs = outputs;

    _computed = true;
  }


  // builder methods

  /// Stack points on point.y by point.x with point.dy values
  DataPointPipeline stack({ double spacing = 0.0 }) {
    _modifiers.add(_StackModifier(spacing));
    return this;
  }

  /// Normalize point.dy values
  DataPointPipeline normalize2pi({
    double total = 2.0,
    double? threshold,
    double? spacing,
    double? spacingDeg,
    bool? trailingSpacing, // true if total >= 2.0 || total <= -2.0 (full circle)
    DataPoint? thresholdPoint,
  }) => normalize(
      total: total * pi,
      threshold: threshold,
      thresholdPoint: thresholdPoint,
      spacing: spacing ?? (spacingDeg != null ? spacingDeg * pi / 180.0 : null ),
      trailingSpacing: trailingSpacing ?? total >= 2.0 || total <= -2.0,
  );

  /// Normalize point.dy values
  DataPointPipeline normalize({
    double total = 1.0,
    double? threshold,
    DataPoint? thresholdPoint,
    double? spacing,
    bool? trailingSpacing,
  }) {
    _modifiers.add(_NormalizeModifier(
      total: total,
      threshold: threshold,
      thresholdPoint: thresholdPoint,
      spacing: spacing,
      trailingSpacing: trailingSpacing,
    ));
    return this;
  }

  /// Linearly rescale values from [currentMin..currentMax] to [targetMin..targetMax].
  ///
  /// By default only [DataPoint.dy] is rescaled.
  /// If [rescaleY] is true, [DataPoint.y] is also transformed by the same mapping.
  ///
  /// If [currentMin] or [currentMax] are not finite, they are computed from input dy values.
  DataPointPipeline rescale({
    double currentMin = double.negativeInfinity,
    double currentMax = double.infinity,
    double targetMin = 0.0,
    double targetMax = 1.0,
    bool rescaleY = false,
  }) {
    _modifiers.add(
      _RescaleModifier(
        currentMin: currentMin,
        currentMax: currentMax,
        targetMin: targetMin,
        targetMax: targetMax,
        rescaleY: rescaleY,
      ),
    );

    return this;
  }
}


class _StackModifier implements DataPointModifier {

  final double spacing;
  const _StackModifier(this.spacing);

  @override
  List<DataPoint> apply(
      List<DataPoint> input,
      DataPointPipelineContext context,
      ) {
    final result = <DataPoint>[];

    for (final p in input) {

      final base = context.cumulativeByX[p.x] ?? 0.0;

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

class _RescaleModifier implements DataPointModifier {
  /// Source dy range.
  /// If either bound is not finite, it is computed from input dy values.
  final double currentMin;
  final double currentMax;

  /// Target range.
  final double targetMin;
  final double targetMax;

  /// If true, apply the same affine transform to DataPoint.y too.
  final bool rescaleY;

  const _RescaleModifier({
    required this.currentMin,
    required this.currentMax,
    required this.targetMin,
    required this.targetMax,
    this.rescaleY = false,
  });

  @override
  List<DataPoint> apply(
      List<DataPoint> input,
      DataPointPipelineContext context,
      ) {
    if (input.isEmpty) return input;

    final computed = _computeMinMaxDY(input);

    final curMin = currentMin.isFinite ? currentMin : computed.$1;
    final curMax = currentMax.isFinite ? currentMax : computed.$2;

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
      final newDy = transform(p.dy);
      final newY = rescaleY ? transform(p.y) : p.y;

      result.add(
        p.copyWith(
          y: newY,
          dy: newDy,
          fy: context.snap(newY + newDy),
        ),
      );
    }

    return result;
  }

  static (double, double) _computeMinMaxDY(List<DataPoint> input) {
    double minDY = double.infinity;
    double maxDY = double.negativeInfinity;

    for (final p in input) {
      final v = p.dy;
      if (v < minDY) minDY = v;
      if (v > maxDY) maxDY = v;
    }

    return (minDY, maxDY);
  }
}