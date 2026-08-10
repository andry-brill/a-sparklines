import '../interfaces/data_point_data.dart';
import 'data_point.dart';
import 'seat_key.dart';
import 'seat_label_builder.dart';


typedef _SeatsAction = void Function(_SeatsBuildState state);

const _seatAreaNotProvided = Object();

class SeatsBuilder {

  final _SeatsBuildConfiguration _configuration;
  final List<_SeatsAction> _actions = [];
  final List<int> _recordingStarts = [];
  final Map<String, List<_SeatsAction>> _namedRecordings = {};

  SeatsBuilder({
    double x = 0.0,
    double y = 0.0,
    double dy = 0.0,
    double z = 0.0,
    double seatDx = 1.0,
    double rowDy = 1.0,
    double gapDx = 0.0,
    double gapDy = 0.0,
    int row = 1,
    int column = 1,
    Object? area,
    Set<Object> tags = const {},
    DataPointDataMap data = const {},
    ISeatLabelBuilder labelBuilder = const NullLabels(),
  }) : _configuration = _SeatsBuildConfiguration(
    x: x,
    y: y,
    dy: dy,
    z: z,
    seatDx: seatDx,
    rowDy: rowDy,
    gapDx: gapDx,
    gapDy: gapDy,
    row: row,
    column: column,
    area: area,
    tags: Set<Object>.unmodifiable(tags),
    data: Map<Type, IDataPointData?>.unmodifiable(data),
    labelBuilder: labelBuilder,
  ) {
    _validateFinite(x, 'x');
    _validateFinite(y, 'y');
    _validateFinite(dy, 'dy');
    _validateFinite(z, 'z');
    _validatePositive(seatDx, 'seatDx');
    _validatePositive(rowDy, 'rowDy');
    _validateGap(gapDx, 'gapDx');
    _validateGap(gapDy, 'gapDy');
  }

  SeatsBuilder seat({
    String? label,
    double? dy,
    double? z,
    Object? area = _seatAreaNotProvided,
    Set<Object>? tags,
    DataPointDataMap data = const {},
  }) {
    if (dy != null) _validateFinite(dy, 'dy');
    if (z != null) _validateFinite(z, 'z');
    _recordSeats(
      count: 1,
      label: label,
      dy: dy,
      z: z,
      area: area,
      hasArea: !identical(area, _seatAreaNotProvided),
      tags: tags,
      data: data,
    );
    return this;
  }

  SeatsBuilder seats(
    int count, {
    ISeatLabelBuilder? labelBuilder,
    double? dy,
    double? z,
    Object? area = _seatAreaNotProvided,
    Set<Object>? tags,
    DataPointDataMap data = const {},
  }) {
    _validateCount(count, 'count');
    if (dy != null) _validateFinite(dy, 'dy');
    if (z != null) _validateFinite(z, 'z');
    _recordSeats(
      count: count,
      labelBuilder: labelBuilder,
      dy: dy,
      z: z,
      area: area,
      hasArea: !identical(area, _seatAreaNotProvided),
      tags: tags,
      data: data,
    );
    return this;
  }

  SeatsBuilder skip([int count = 1]) {
    _validateCount(count, 'count');
    _actions.add((state) => state.skip(count));
    return this;
  }

  SeatsBuilder nextRow([int count = 1]) {
    _validateCount(count, 'count');
    _actions.add((state) => state.nextRow(count));
    return this;
  }

  SeatsBuilder gap({
    double? gapDx,
    double? gapDy,
  }) {
    if (gapDx != null) _validateGap(gapDx, 'gapDx');
    if (gapDy != null) _validateGap(gapDy, 'gapDy');
    _actions.add((state) {
      if (gapDx != null) state.gapDx = gapDx;
      if (gapDy != null) state.gapDy = gapDy;
    });
    return this;
  }

  SeatsBuilder area(Object? area) {
    _actions.add((state) => state.area = area);
    return this;
  }

  SeatsBuilder tags(Set<Object> tags) {
    final recordedTags = Set<Object>.unmodifiable(tags);
    _actions.add((state) => state.tags = recordedTags);
    return this;
  }

  SeatsBuilder data(DataPointDataMap data) {
    final recordedData = Map<Type, IDataPointData?>.unmodifiable(data);
    _actions.add((state) => state.data = recordedData);
    return this;
  }

  SeatsBuilder saveState({
    String? key,
    bool gap = true,
    bool area = true,
    bool tags = true,
    bool data = true,
  }) {
    _recordStateSnapshot(key: key, gap: gap, area: area, tags: tags, data: data);
    return this;
  }

  SeatsBuilder saveOnlyState({
    String? key,
    bool gap = false,
    bool area = false,
    bool tags = false,
    bool data = false,
  }) {
    _recordStateSnapshot(key: key, gap: gap, area: area, tags: tags, data: data);
    return this;
  }

  SeatsBuilder restoreState([String? key]) {
    _actions.add((state) => state.restoreState(key));
    return this;
  }

  SeatsBuilder record() {
    _recordingStarts.add(_actions.length);
    return this;
  }

  SeatsBuilder saveRecord({required String key}) {
    if (_namedRecordings.containsKey(key)) {
      throw ArgumentError.value(key, 'key', 'a recording with this key already exists');
    }
    _namedRecordings[key] = _closeRecording('saveRecord() requires an open record() block');
    return this;
  }

  SeatsBuilder repeat(int count, {String? key}) {
    _validateCount(count, 'count');
    if (key != null) {
      final recorded = _namedRecordings[key];
      if (recorded == null) {
        throw StateError('No recording exists for key "$key"');
      }
      _addRepeatedActions(recorded, count);
      return this;
    }
    final recorded = _closeRecording('repeat() requires an open record() block');
    _addRepeatedActions(recorded, count);
    return this;
  }

  List<DataPoint> build() {
    if (_recordingStarts.isNotEmpty) {
      throw StateError('Every record() block must be closed by repeat() or saveRecord() before build()');
    }
    final state = _SeatsBuildState(_configuration);
    for (final action in _actions) {
      action(state);
    }
    state.validateLabels();
    return List<DataPoint>.unmodifiable(state.points);
  }

  void _recordStateSnapshot({
    required String? key,
    required bool gap,
    required bool area,
    required bool tags,
    required bool data,
  }) {
    _actions.add((state) => state.saveState(key: key, gap: gap, area: area, tags: tags, data: data));
  }

  List<_SeatsAction> _closeRecording(String error) {
    if (_recordingStarts.isEmpty) {
      throw StateError(error);
    }
    final start = _recordingStarts.removeLast();
    final recorded = List<_SeatsAction>.unmodifiable(_actions.sublist(start));
    _actions.removeRange(start, _actions.length);
    return recorded;
  }

  void _addRepeatedActions(List<_SeatsAction> recorded, int count) {
    if (count == 0) return;
    _actions.add((state) {
      for (var i = 0; i < count; i++) {
        for (final action in recorded) {
          action(state);
        }
      }
    });
  }

  void _recordSeats({
    required int count,
    String? label,
    ISeatLabelBuilder? labelBuilder,
    double? dy,
    double? z,
    Object? area,
    required bool hasArea,
    Set<Object>? tags,
    required DataPointDataMap data,
  }) {
    final recordedTags = tags == null ? null : Set<Object>.unmodifiable(tags);
    final recordedData = Map<Type, IDataPointData?>.unmodifiable(data);
    _actions.add((state) => state.addSeats(
      count: count,
      label: label,
      labelBuilder: labelBuilder,
      dy: dy,
      z: z,
      area: area,
      hasArea: hasArea,
      tags: recordedTags,
      data: recordedData,
    ));
  }

  static void _validateFinite(double value, String name) {
    if (!value.isFinite) {
      throw ArgumentError.value(value, name, 'must be finite');
    }
  }

  static void _validatePositive(double value, String name) {
    if (!value.isFinite || value <= 0.0) {
      throw ArgumentError.value(value, name, 'must be finite and greater than zero');
    }
  }

  static void _validateGap(double value, String name) {
    if (!value.isFinite || value < 0.0) {
      throw ArgumentError.value(value, name, 'must be finite and non-negative');
    }
  }

  static void _validateCount(int value, String name) {
    if (value < 0) {
      throw ArgumentError.value(value, name, 'must be non-negative');
    }
  }

}

class _SeatsBuildConfiguration {

  final double x;
  final double y;
  final double dy;
  final double z;
  final double seatDx;
  final double rowDy;
  final double gapDx;
  final double gapDy;
  final int row;
  final int column;
  final Object? area;
  final Set<Object> tags;
  final DataPointDataMap data;
  final ISeatLabelBuilder labelBuilder;

  const _SeatsBuildConfiguration({
    required this.x,
    required this.y,
    required this.dy,
    required this.z,
    required this.seatDx,
    required this.rowDy,
    required this.gapDx,
    required this.gapDy,
    required this.row,
    required this.column,
    required this.area,
    required this.tags,
    required this.data,
    required this.labelBuilder,
  });

}

class _SeatsBuildState {

  final double startX;
  final double seatDx;
  final double rowDy;
  final int startColumn;
  final ISeatLabelBuilder defaultLabelBuilder;
  final List<ISeatLabelBuilder> labelBuilders;

  double currentX;
  double currentY;
  double dy;
  double z;
  double gapDx;
  double gapDy;
  int currentRow;
  int currentColumn;
  int slotsInRow = 0;
  Object? area;
  Set<Object> tags;
  DataPointDataMap data;

  final List<DataPoint> points = [];
  final Set<SeatKey> identities = {};
  final List<_SeatsStateSnapshot> stateSnapshots = [];
  final Map<String, _SeatsStateSnapshot> namedStateSnapshots = {};

  _SeatsBuildState(_SeatsBuildConfiguration configuration) :
    startX = configuration.x,
    currentX = configuration.x,
    currentY = configuration.y,
    dy = configuration.dy,
    z = configuration.z,
    seatDx = configuration.seatDx,
    rowDy = configuration.rowDy,
    gapDx = configuration.gapDx,
    gapDy = configuration.gapDy,
    currentRow = configuration.row,
    startColumn = configuration.column,
    currentColumn = configuration.column,
    area = configuration.area,
    tags = configuration.tags,
    data = configuration.data,
    defaultLabelBuilder = configuration.labelBuilder,
    labelBuilders = [configuration.labelBuilder];

  void addSeats({
    required int count,
    String? label,
    ISeatLabelBuilder? labelBuilder,
    double? dy,
    double? z,
    Object? area,
    required bool hasArea,
    Set<Object>? tags,
    required DataPointDataMap data,
  }) {
    final effectiveLabelBuilder = labelBuilder ?? defaultLabelBuilder;
    if (!labelBuilders.any((builder) => identical(builder, effectiveLabelBuilder))) {
      labelBuilders.add(effectiveLabelBuilder);
    }
    for (var i = 0; i < count; i++) {
      final effectiveArea = hasArea ? area : this.area;
      final effectiveTags = tags ?? this.tags;
      final effectiveLabel = label ?? effectiveLabelBuilder.next(currentRow, currentColumn, effectiveArea);
      final key = SeatKey(
        label: effectiveLabel,
        row: currentRow,
        column: currentColumn,
        area: effectiveArea,
        tags: effectiveTags,
      );
      if (identities.contains(key)) {
        throw ArgumentError.value(key, 'SeatKey', 'duplicate area, row, and column');
      }

      points.add(DataPoint(
        x: _consumeSlot(),
        y: currentY,
        dy: dy ?? this.dy,
        z: z ?? this.z,
        key: key,
        data: Map<Type, IDataPointData?>.unmodifiable(this.data.copyWith(data)),
      ));
      identities.add(key);
      currentColumn++;
    }
  }

  void skip(int count) {
    for (var i = 0; i < count; i++) {
      _consumeSlot();
      currentColumn++;
    }
  }

  void nextRow(int count) {
    if (count == 0) return;
    final nextY = currentY + count * (rowDy + gapDy);
    SeatsBuilder._validateFinite(nextY, 'y');
    currentY = nextY;
    currentRow += count;
    currentX = startX;
    currentColumn = startColumn;
    slotsInRow = 0;
  }

  void saveState({
    required String? key,
    required bool gap,
    required bool area,
    required bool tags,
    required bool data,
  }) {
    final snapshot = _SeatsStateSnapshot(
      hasGap: gap,
      hasArea: area,
      hasTags: tags,
      hasData: data,
      gapDx: gapDx,
      gapDy: gapDy,
      area: this.area,
      tags: this.tags,
      data: this.data,
    );
    if (key == null) {
      stateSnapshots.add(snapshot);
    } else {
      namedStateSnapshots[key] = snapshot;
    }
  }

  void restoreState(String? key) {
    final _SeatsStateSnapshot snapshot;
    if (key == null) {
      if (stateSnapshots.isEmpty) {
        throw StateError('No anonymous state snapshot exists');
      }
      snapshot = stateSnapshots.removeLast();
    } else {
      final namedSnapshot = namedStateSnapshots[key];
      if (namedSnapshot == null) {
        throw StateError('No state snapshot exists for key "$key"');
      }
      snapshot = namedSnapshot;
    }
    snapshot.restore(this);
  }

  void validateLabels() {
    Object? firstError;
    StackTrace? firstStackTrace;
    for (final labelBuilder in labelBuilders) {
      try {
        labelBuilder.validate();
      } catch (error, stackTrace) {
        firstError ??= error;
        firstStackTrace ??= stackTrace;
      }
    }
    if (firstError != null) {
      Error.throwWithStackTrace(firstError, firstStackTrace!);
    }
  }

  double _consumeSlot() {
    if (slotsInRow > 0) {
      final nextX = currentX + seatDx + gapDx;
      SeatsBuilder._validateFinite(nextX, 'x');
      currentX = nextX;
    }
    slotsInRow++;
    return currentX;
  }

}

class _SeatsStateSnapshot {

  final bool hasGap;
  final bool hasArea;
  final bool hasTags;
  final bool hasData;
  final double gapDx;
  final double gapDy;
  final Object? area;
  final Set<Object> tags;
  final DataPointDataMap data;

  const _SeatsStateSnapshot({
    required this.hasGap,
    required this.hasArea,
    required this.hasTags,
    required this.hasData,
    required this.gapDx,
    required this.gapDy,
    required this.area,
    required this.tags,
    required this.data,
  });

  void restore(_SeatsBuildState state) {
    if (hasGap) {
      state.gapDx = gapDx;
      state.gapDy = gapDy;
    }
    if (hasArea) state.area = area;
    if (hasTags) state.tags = tags;
    if (hasData) state.data = data;
  }

}
