import 'dart:ui' show lerpDouble;
import 'dart:math' as math;

import 'package:any_sparklines/interfaces/pie_offset.dart';

import '../interfaces/data_point_data.dart';
import '../interfaces/data_point_style.dart';
import '../interfaces/lerp.dart';
import '../interfaces/thickness.dart';


typedef DataPoints = List<DataPoint>;

/// A single data point with x, y coordinates and optional style
/// DataPoint could be used as interface if needed
class DataPoint implements ILerpTo<DataPoint> {

  /// Offset by X
  final double x;

  /// Offset by Y
  final double y;

  /// Value
  final double dy;

  /// Full Y (y + dy)
  final double fy;

  final DataPointDataMap data;

  const DataPoint({
    required this.x,
    this.y = 0.0,
    required this.dy,
    this.data = const {},
    /// Can be used in case need in snap function
    double? fy
  }) : fy = fy ?? (y + dy);

  DataPoint copyWith({
    double? x,
    double? dx,
    double? y,
    double? dy,
    double? fy,
    DataPointDataMap? data,
  }) => DataPoint(
    x: x ?? this.x,
    y: y ?? this.y,
    dy: dy ?? this.dy,
    fy: fy, // NB! Must be without ?? this.fy,
    data: data != null ? this.data.copyWith(data) : this.data,
  );

  @override
  DataPoint lerpTo(DataPoint next, double t) {
    return DataPoint(
      x: lerpDouble(x, next.x, t) ?? next.x,
      y: lerpDouble(y, next.y, t) ?? next.y,
      dy: lerpDouble(dy, next.dy, t) ?? next.dy,
      data: data.lerpTo(next.data, t)
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! DataPoint) return false;

    if (data.isNotEmpty || other.data.isNotEmpty) {

      if (data.length != other.data.length) return false;

      for (var entry in other.data.entries) {
        if (data[entry.key] != entry.value) {
          return false;
        }
      }
    }

    return this.y == other.y && this.x == other.x && this.dy == other.dy;
  }
}

extension DataPointExtension on DataPoint {

  M? of<M>() => data[M] as M?;

  IThicknessOverride? get thickness => of<IThicknessOverride>();
  IDataPointStyle? get style => of<IDataPointStyle>();
  IPieOffset? get pieOffset => of<IPieOffset>();

}

/// Extension on Iterable<DataPoint> for calculating bounds
extension DataPointBounds on Iterable<DataPoint> {
  /// Minimum X coordinate
  double get minX {
    if (isEmpty) return 0.0;
    return map((p) => p.x).reduce((a, b) => math.min(a, b));
  }

  /// Maximum X coordinate
  double get maxX {
    if (isEmpty) return 1.0;
    return map((p) => p.x).reduce((a, b) => math.max(a, b));
  }

  /// Minimum Y coordinate (includes both offset y and final fy for correct bar/line bounds)
  double get minY {
    if (isEmpty) return 0.0;
    return map((p) => math.min(p.y, p.fy)).reduce((a, b) => math.min(a, b));
  }

  /// Maximum Y coordinate (includes both offset y and final fy for correct bar/line bounds)
  double get maxY {
    if (isEmpty) return 1.0;
    return map((p) => math.max(p.y, p.fy)).reduce((a, b) => math.max(a, b));
  }

  double get sumDY {
    double sum = 0.0;
    for (var point in this) {
      sum += point.dy;
    }
    return sum;
  }
}

