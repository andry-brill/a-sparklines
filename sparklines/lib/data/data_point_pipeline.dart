import 'dart:collection';
import 'dart:math';

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

  /// spacing between points in normalized units
  final double spacing;
  DataPointPipelineContext({required this.spacing});

  final cumulativeByX = <double, double>{};

  double globalMinY = double.infinity;
  double globalMaxY = double.negativeInfinity;

  void updateBounds(Iterable<DataPoint> points) {
    globalMinY = min(globalMinY, points.minY);
    globalMaxY = max(globalMaxY, points.maxY);
  }

}


class DataPointPipeline {

  final DataPointPipelineContext context;

  DataPointPipeline({double spacing = 0.0}) : context = DataPointPipelineContext(spacing: spacing);

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
  DataPointPipeline stack([bool enabled = true]) {
    if (enabled) _modifiers.add(StackModifier());
    return this;
  }

  /// Normalize point.dy values
  DataPointPipeline normalize2pi({
    double low = 0.0,
    double high = 2 * pi,
    double? mid,
    double? threshold,
  }) => normalize(low: low, high: high, mid: mid, threshold: threshold);

  /// Normalize point.dy values
  DataPointPipeline normalize({
    double low = 0.0,
    double high = 1.0,
    double? mid,
    double? threshold,
  }) {
    _modifiers.add(NormalizeModifier(
      low: low,
      high: high,
      mid: mid,
      threshold: threshold,
    ));
    return this;
  }

}


class StackModifier implements DataPointModifier {

  @override
  List<DataPoint> apply(
      List<DataPoint> input,
      DataPointPipelineContext context,
      ) {
    final result = <DataPoint>[];

    for (final p in input) {
      final base = context.cumulativeByX[p.x] ?? 0.0;

      result.add(p.copyWith(y: base));

      context.cumulativeByX[p.x] = base + p.dy + context.spacing;
    }

    return result;
  }
}


class NormalizeModifier implements DataPointModifier {

  final double low;
  final double? mid;
  final double high;

  /// threshold in normalized units
  final double? threshold;

  NormalizeModifier({
    required this.low,
    required this.high,
    this.mid,
    this.threshold,
  }) : assert(low < high);

  @override
  List<DataPoint> apply(
      List<DataPoint> input,
      DataPointPipelineContext context,
      ) {

    if (input.isEmpty) return input;

    var working = List<DataPoint>.from(input);

    while (true) {

      final normalized = _normalizeOnce(working, context);

      if (threshold == null) {
        return normalized;
      }

      // find smallest absolute normalized dy below threshold
      double minValue = double.infinity;

      for (final p in normalized) {
        final v = p.dy.abs();
        if (v < threshold! && v < minValue) {
          minValue = v;
        }
      }

      // nothing to remove → done
      if (minValue == double.infinity) {
        return normalized;
      }

      // remove the corresponding original datapoint
      final indexToRemove = normalized.indexWhere(
            (p) => p.dy.abs() == minValue,
      );

      if (indexToRemove == -1) {
        return normalized;
      }

      working.removeAt(indexToRemove);

      if (working.isEmpty) {
        return const [];
      }
    }
  }

  List<DataPoint> _normalizeOnce(List<DataPoint> input, DataPointPipelineContext context) {

    double negSum = 0;
    double posSum = 0;

    for (final p in input) {
      if (p.dy < 0) negSum += -p.dy + (negSum > 0 ? context.spacing : 0.0);
      else if (p.dy > 0) posSum += p.dy + (posSum > 0 ? context.spacing : 0.0);
    }

    final total = negSum + posSum + (negSum > 0 && posSum > 0 ? context.spacing : 0.0);

    if (total == 0) return input;

    final split = mid ?? (low + (negSum / total) * (high - low));
    final negRange = split - low;
    final posRange = high - split;

    final negScale = negSum == 0 ? 0 : negRange / negSum;
    final posScale = posSum == 0 ? 0 : posRange / posSum;

    final result = <DataPoint>[];

    for (final p in input) {

      final dy = p.dy;

      double newDy = 0.0;

      if (dy < 0) {
        newDy = (-dy) * negScale;
      } else if (dy > 0) {
        newDy = dy * posScale;
      }

      result.add(p.copyWith(dy: newDy));
    }

    return result;
  }
}

