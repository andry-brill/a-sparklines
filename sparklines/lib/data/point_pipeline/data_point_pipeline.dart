library;

import 'dart:collection';
import 'dart:math';

import 'package:any_sparklines/interfaces/data_point_data.dart';

import '../data_point.dart';

part '_sort_modifier.dart';
part '_stack_modifier.dart';
part '_normalize_modifier.dart';
part '_rescale_modifier.dart';
part '_aggregation_modifier.dart';

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
  /// [offset] - initial offset for the first point on point.x
  DataPointPipeline stack({ double offset = 0.0, double spacing = 0.0 }) {
    _modifiers.add(_StackModifier(offset: offset, spacing: spacing));
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
  DataPointPipeline aggregate({DataAggregation function = DataAggregation.sum, int? window}) {
    _modifiers.add(_AggregationModifier(function: function, window: window));
    return this;
  }

}


enum DataAggregation {

  sum,
  avg,

  min,
  max,

  /// Using center element when the number of values in the window is odd
  /// Using average of the two center elements when the number of values in the window is even
  median,

  /// Standard deviation
  std
}
