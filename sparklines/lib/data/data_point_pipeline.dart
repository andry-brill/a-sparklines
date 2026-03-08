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

  /// Bounds used by [RescaleModifier] when currentMin/currentMax are not finite.
  /// Accumulated across all input lists (similar to stacking).
  double rescaleMinY = double.infinity;
  double rescaleMaxY = double.negativeInfinity;

  void updateBounds(Iterable<DataPoint> points) {
    globalMinY = min(globalMinY, points.minY);
    globalMaxY = max(globalMaxY, points.maxY);
  }

  void updateRescaleBounds(Iterable<DataPoint> points) {
    for (final p in points) {
      final a = min(p.y, p.fy);
      final b = max(p.y, p.fy);
      if (a < rescaleMinY) rescaleMinY = a;
      if (b > rescaleMaxY) rescaleMaxY = b;
    }
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

  bool _hasRescaleWithAutoBounds() {
    for (final m in _modifiers) {
      if (m is _RescaleModifier &&
          (!m.currentMin.isFinite || !m.currentMax.isFinite)) {
        return true;
      }
    }
    return false;
  }

  void _computeIfNeeded() {

    if (_computed) return;

    final needRescaleBoundsPass = _hasRescaleWithAutoBounds();

    if (needRescaleBoundsPass) {
      context.rescaleMinY = double.infinity;
      context.rescaleMaxY = double.negativeInfinity;
      for (final input in _inputs) {
        var result = input;
        for (final modifier in _modifiers) {
          if (modifier is _RescaleModifier &&
              (!modifier.currentMin.isFinite ||
                  !modifier.currentMax.isFinite)) {
            context.updateRescaleBounds(result);
            break;
          }
          result = modifier.apply(result, context);
        }
      }
    }

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

  /// Linearly rescale intervals [DataPoint.y..DataPoint.fy]
  /// from [currentMin..currentMax] to [targetMin..targetMax].
  ///
  /// Both y and fy are transformed, and dy is recalculated as (fy - y).
  DataPointPipeline rescale({
    double currentMin = double.negativeInfinity,
    double currentMax = double.infinity,
    double targetMin = 0.0,
    double targetMax = 1.0,
  }) {
    _modifiers.add(
      _RescaleModifier(
        currentMin: currentMin,
        currentMax: currentMax,
        targetMin: targetMin,
        targetMax: targetMax,
      ),
    );

    return this;
  }

  /// Sort input by x, y, and/or fy.
  /// [x], [y], [fy]: if true => ascending, if false => descending.
  /// If all are null, sorts by x ascending by default.
  DataPointPipeline sort({bool? x, bool? y, bool? fy}) {
    _modifiers.add(_SortModifier(x: x, y: y, fy: fy));
    return this;
  }

  /// Aggregates values (dy) using a window that ends at the current element.
  ///
  /// If [window] is `null`, the window includes all elements from the start
  /// up to and including the current element.
  ///
  /// If [window] is `N`, the window includes up to `N` elements ending at
  /// the current element. For the first elements, the window may contain
  /// fewer than `N` elements.
  DataPointPipeline aggregate({Aggregation function = Aggregation.sum, int? window}) {
    // TODO _AggregationModifier
    return this;
  }

}


class _SortModifier implements DataPointModifier {

  final bool? x;
  final bool? y;
  final bool? fy;

  const _SortModifier({this.x, this.y, this.fy});

  @override
  List<DataPoint> apply(
      List<DataPoint> input,
      DataPointPipelineContext context,
      ) {
    if (input.isEmpty) return input;

    final allNull = x == null && y == null && fy == null;
    final sortX = x ?? (allNull ? true : null);
    final sortY = y;
    final sortFy = fy;

    final result = List<DataPoint>.from(input);

    result.sort((a, b) {
      if (sortX != null) {
        final c = sortX ? a.x.compareTo(b.x) : b.x.compareTo(a.x);
        if (c != 0) return c;
      }
      if (sortY != null) {
        final c = sortY ? a.y.compareTo(b.y) : b.y.compareTo(a.y);
        if (c != 0) return c;
      }
      if (sortFy != null) {
        final c = sortFy ? a.fy.compareTo(b.fy) : b.fy.compareTo(a.fy);
        if (c != 0) return c;
      }
      return 0;
    });

    return result;
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


enum Aggregation {

  sum,
  avg,

  min,
  max,

  /// Using center element when the number of values in the window is odd
  /// Using average of the two center elements when the number of values in the window is even
  median,

  /// Standard deviation
  stddev
}