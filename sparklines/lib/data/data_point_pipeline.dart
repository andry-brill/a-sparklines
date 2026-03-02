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
    DataPoint? thresholdPoint,
  }) => normalize(total: total * pi, threshold: threshold, spacing: spacing, thresholdPoint: thresholdPoint);

  /// Normalize point.dy values
  DataPointPipeline normalize({
    double total = 1.0,
    double? threshold,
    double? spacing,
    DataPoint? thresholdPoint,
  }) {
    _modifiers.add(_NormalizeModifier(
      total: total,
      threshold: threshold,
      spacing: spacing,
      thresholdPoint: thresholdPoint,
    ));
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

  /// When set, removed (below-threshold) points' dy is accumulated here
  final DataPoint? thresholdPoint;

  _NormalizeModifier({
    required this.total,
    double? threshold,
    double? spacing,
    this.thresholdPoint,
  }) :
        assert(total >= 0.0),
        assert(spacing == null || spacing >= 0.0),
        assert(threshold == null || threshold >= 0.0),
    spacing = spacing ?? 0.0,
    threshold = threshold ?? 0.0
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

    double availableTotal = context.snap(max(0.0, total - spacing * (input.length - 1)));
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


