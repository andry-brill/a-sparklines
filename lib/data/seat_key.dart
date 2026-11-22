import 'package:flutter/foundation.dart';

import 'data_point.dart';


@immutable
class SeatKey {

  final String? label;
  final int row;
  final int column;
  final Object? area;
  final Set<Object> tags;

  SeatKey({
    required this.label,
    required this.row,
    required this.column,
    this.area,
    Set<Object> tags = const {},
  }) : tags = Set<Object>.unmodifiable(tags);

  @override
  bool operator ==(Object other) => identical(this, other) || other is SeatKey && row == other.row && column == other.column && area == other.area;

  @override
  int get hashCode => Object.hash(row, column, area);

}

@immutable
class SeatSelector {

  final Set<String> labels;
  final Set<int> rows;
  final Set<int> columns;
  final Set<Object?> areas;
  final Set<Set<Object>> tags;

  SeatSelector({
    Set<String> labels = const {},
    Set<int> rows = const {},
    Set<int> columns = const {},
    Set<Object?> areas = const {},
    Set<Set<Object>> tags = const {},
  }) :
    labels = Set<String>.unmodifiable(labels),
    rows = Set<int>.unmodifiable(rows),
    columns = Set<int>.unmodifiable(columns),
    areas = Set<Object?>.unmodifiable(areas),
    tags = Set<Set<Object>>.unmodifiable(tags.map((group) => Set<Object>.unmodifiable(group)));

  bool matches(SeatKey key) {
    if (labels.isNotEmpty && !labels.contains(key.label)) return false;
    if (rows.isNotEmpty && !rows.contains(key.row)) return false;
    if (columns.isNotEmpty && !columns.contains(key.column)) return false;
    if (areas.isNotEmpty && !areas.contains(key.area)) return false;
    return tags.isEmpty || tags.any((group) => group.every(key.tags.contains));
  }

}

typedef SeatPredicate = bool Function(DataPoint point, SeatKey key);
