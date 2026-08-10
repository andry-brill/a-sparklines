import 'package:any_sparklines/any_sparklines.dart';
import 'package:flutter/material.dart' show Colors;
import 'package:test/test.dart';


enum _SeatTag { vip, window, aisle, accessible }

class _FirstData extends ADataPointPlainData<_FirstData> {

  final String value;

  const _FirstData(this.value);

}

class _SecondData extends ADataPointPlainData<_SecondData> {

  final String value;

  const _SecondData(this.value);

}

class _RecordingLabels implements ISeatLabelBuilder {

  final List<String?> labels;

  int nextCalls = 0;
  int validateCalls = 0;

  _RecordingLabels(this.labels);

  @override
  String? next(int row, int column, Object? area) => labels[nextCalls++];

  @override
  void validate() {
    validateCalls++;
  }

}

class _CoordinateLabels implements ISeatLabelBuilder {

  const _CoordinateLabels();

  @override
  String next(int row, int column, Object? area) => '$row:$column';

  @override
  void validate() {}

}

void main() {

  group('SeatKey and SeatSelector', () {

    test('seat identity uses area, row, and column but not label or tags', () {
      final mutableTags = <Object>{_SeatTag.vip};
      final key = SeatKey(label: '12A', row: 1, column: 2, area: 'main', tags: mutableTags);
      final sameIdentity = SeatKey(label: 'database-id', row: 1, column: 2, area: 'main', tags: {_SeatTag.window});
      mutableTags.add(_SeatTag.window);

      expect(key, equals(sameIdentity));
      expect(key.hashCode, equals(sameIdentity.hashCode));
      expect(key.tags, equals({_SeatTag.vip}));
      expect(() => key.tags.add(_SeatTag.window), throwsUnsupportedError);
      expect(key, isNot(SeatKey(label: '12A', row: 2, column: 2, area: 'main')));
      expect(key, isNot(SeatKey(label: '12A', row: 1, column: 3, area: 'main')));
      expect(key, isNot(SeatKey(label: '12A', row: 1, column: 2, area: 'other')));
    });

    test('selector uses OR within fields, AND across fields, and OR-of-AND tag groups', () {
      final key = SeatKey(label: '3D', row: 3, column: 4, tags: {_SeatTag.vip, _SeatTag.window});

      expect(SeatSelector().matches(key), isTrue);
      expect(SeatSelector(labels: {'other', '3D'}, rows: {2, 3}, columns: {4, 5}, areas: {'main', null}, tags: {{_SeatTag.aisle}, {_SeatTag.vip, _SeatTag.window}}).matches(key), isTrue);
      expect(SeatSelector(labels: {'other'}).matches(key), isFalse);
      expect(SeatSelector(rows: {1, 2}).matches(key), isFalse);
      expect(SeatSelector(columns: {1, 2}).matches(key), isFalse);
      expect(SeatSelector(areas: {'main'}).matches(key), isFalse);
      expect(SeatSelector(tags: {{_SeatTag.vip, _SeatTag.aisle}, {_SeatTag.accessible}}).matches(key), isFalse);
    });

    test('selector snapshots every set including nested tag groups', () {
      final labels = {'3D'};
      final requiredTags = <Object>{_SeatTag.vip};
      final tagGroups = <Set<Object>>{requiredTags};
      final selector = SeatSelector(labels: labels, tags: tagGroups);
      labels.clear();
      requiredTags.add(_SeatTag.aisle);
      tagGroups.clear();
      final key = SeatKey(label: '3D', row: 3, column: 4, tags: {_SeatTag.vip});

      expect(selector.matches(key), isTrue);
      expect(() => selector.labels.add('4A'), throwsUnsupportedError);
      expect(() => selector.tags.first.add(_SeatTag.window), throwsUnsupportedError);
    });
  });

  group('SeatsBuilder', () {

    test('seat actions are deferred and generate or override labels during build', () {
      final defaultLabels = _RecordingLabels(['main-5-7']);
      final groupLabels = _RecordingLabels(['group-5-9']);
      final builder = SeatsBuilder(
        x: 10.0,
        y: 20.0,
        dy: 1.0,
        z: 2.0,
        row: 5,
        column: 7,
        area: 'main',
        tags: {_SeatTag.vip},
        labelBuilder: defaultLabels,
      )
          .seat()
          .seat(label: 'custom', dy: 3.0, z: 4.0, area: 'other', tags: {_SeatTag.aisle})
          .seats(1, labelBuilder: groupLabels);

      expect(defaultLabels.nextCalls, equals(0));
      expect(defaultLabels.validateCalls, equals(0));
      expect(groupLabels.nextCalls, equals(0));
      final points = builder.build();

      expect(defaultLabels.nextCalls, equals(1));
      expect(defaultLabels.validateCalls, equals(1));
      expect(groupLabels.nextCalls, equals(1));
      expect(groupLabels.validateCalls, equals(1));
      expect(points.length, equals(3));
      expect(points[0].x, equals(10.0));
      expect(points[0].y, equals(20.0));
      expect(points[0].dy, equals(1.0));
      expect(points[0].fy, equals(21.0));
      expect(points[0].z, equals(2.0));
      expect((points[0].key! as SeatKey).label, equals('main-5-7'));
      expect((points[0].key! as SeatKey).tags, equals({_SeatTag.vip}));
      expect((points[1].key! as SeatKey).label, equals('custom'));
      expect((points[1].key! as SeatKey).area, equals('other'));
      expect((points[1].key! as SeatKey).tags, equals({_SeatTag.aisle}));
      expect(points[1].dy, equals(3.0));
      expect(points[1].z, equals(4.0));
      expect((points[2].key! as SeatKey).label, equals('group-5-9'));
    });

    test('NullLabels leaves labels null by default', () {
      final points = SeatsBuilder(row: 12, column: 3).seats(2).build();

      expect(points.map((point) => (point.key! as SeatKey).label), orderedEquals([null, null]));
    });

    test('ListLabels consumes every label, validates, snapshots input, and resets after build', () {
      final inputLabels = ['12A', '12B'];
      final labels = ListLabels(inputLabels);
      final builder = SeatsBuilder(labelBuilder: labels).seats(2);
      inputLabels.add('12C');

      expect(builder.build().map((point) => (point.key! as SeatKey).label), orderedEquals(['12A', '12B']));
      expect(builder.build().map((point) => (point.key! as SeatKey).label), orderedEquals(['12A', '12B']));
      expect(labels.labels, orderedEquals(['12A', '12B']));
      expect(() => labels.labels.add('12C'), throwsUnsupportedError);
    });

    test('ListLabels rejects missing and unused labels', () {
      expect(() => SeatsBuilder(labelBuilder: ListLabels(['1A'])).seats(2).build(), throwsStateError);

      final builder = SeatsBuilder(labelBuilder: ListLabels(['1A', '1B'])).seat();
      expect(() => builder.build(), throwsStateError);
      expect(builder.seat().build().map((point) => (point.key! as SeatKey).label), orderedEquals(['1A', '1B']));
    });

    test('per-call null area temporarily overrides a non-null default', () {
      final points = SeatsBuilder(area: 'main')
          .seat(area: null)
          .seat()
          .build();

      expect((points[0].key! as SeatKey).area, isNull);
      expect((points[1].key! as SeatKey).area, equals('main'));
    });

    test('horizontal and vertical gaps are additional persistent distances', () {
      final points = SeatsBuilder(seatDx: 2.0, rowDy: 3.0, gapDx: 0.5, gapDy: 1.0)
          .seat()
          .seat()
          .gap(gapDx: 1.5)
          .seat()
          .nextRow()
          .seat()
          .seat()
          .build();

      expect(points.map((point) => point.x), orderedEquals([0.0, 2.5, 6.0, 0.0, 3.5]));
      expect(points.map((point) => point.y), orderedEquals([0.0, 0.0, 0.0, 4.0, 4.0]));
      expect(points.map((point) => (point.key! as SeatKey).row), orderedEquals([1, 1, 1, 2, 2]));
      expect(points.map((point) => (point.key! as SeatKey).column), orderedEquals([1, 2, 3, 1, 2]));
    });

    test('gap changes either axis independently, persists, and does not move immediately', () {
      final points = SeatsBuilder(seatDx: 1.0, rowDy: 2.0, gapDx: 0.25, gapDy: 0.5)
          .seat()
          .gap()
          .gap(gapDx: 1.0)
          .seat()
          .gap(gapDy: 2.0)
          .nextRow(2)
          .seat()
          .seat()
          .build();

      expect(points.map((point) => point.x), orderedEquals([0.0, 2.0, 0.0, 2.0]));
      expect(points.map((point) => point.y), orderedEquals([0.0, 0.0, 8.0, 8.0]));
      expect((points[2].key! as SeatKey).row, equals(3));
    });

    test('skip consumes full slots and columns without emitting points', () {
      final points = SeatsBuilder(x: 5.0, seatDx: 2.0, gapDx: 0.5, column: 3)
          .skip(2)
          .seat()
          .skip()
          .seat()
          .build();

      expect(points.map((point) => point.x), orderedEquals([10.0, 15.0]));
      expect(points.map((point) => (point.key! as SeatKey).column), orderedEquals([5, 7]));
    });

    test('record and repeat execute the block count times in total', () {
      final points = SeatsBuilder(labelBuilder: const _CoordinateLabels())
          .record()
          .seats(2)
          .skip()
          .seat()
          .nextRow()
          .repeat(3)
          .build();

      expect(points.length, equals(9));
      expect(points.map((point) => point.x), orderedEquals([0.0, 1.0, 3.0, 0.0, 1.0, 3.0, 0.0, 1.0, 3.0]));
      expect(points.map((point) => point.y), orderedEquals([0.0, 0.0, 0.0, 1.0, 1.0, 1.0, 2.0, 2.0, 2.0]));
      expect(points.map((point) => (point.key! as SeatKey).label), orderedEquals(['1:1', '1:2', '1:4', '2:1', '2:2', '2:4', '3:1', '3:2', '3:4']));
    });

    test('record blocks can be nested and repeat zero removes its block', () {
      final points = SeatsBuilder()
          .record()
          .record()
          .seat()
          .nextRow()
          .repeat(2)
          .repeat(2)
          .record()
          .seat()
          .repeat(0)
          .build();

      expect(points.map((point) => (point.key! as SeatKey).row), orderedEquals([1, 2, 3, 4]));
    });

    test('saved records remain unapplied until replayed from the current cursor', () {
      final builder = SeatsBuilder(labelBuilder: const _CoordinateLabels())
          .record()
          .seats(2)
          .skip()
          .seat()
          .nextRow()
          .saveRecord(key: 'row');

      expect(builder.build(), isEmpty);
      final points = builder
          .repeat(2, key: 'row')
          .nextRow()
          .repeat(2, key: 'row')
          .build();

      expect(points.map((point) => point.y), orderedEquals([0.0, 0.0, 0.0, 1.0, 1.0, 1.0, 3.0, 3.0, 3.0, 4.0, 4.0, 4.0]));
      expect(points.map((point) => (point.key! as SeatKey).label), orderedEquals(['1:1', '1:2', '1:4', '2:1', '2:2', '2:4', '4:1', '4:2', '4:4', '5:1', '5:2', '5:4']));
    });

    test('saved records use current defaults and compose inside recordings', () {
      final points = SeatsBuilder()
          .record()
          .seats(2)
          .nextRow()
          .saveRecord(key: 'row')
          .repeat(1, key: 'row')
          .area('business')
          .gap(gapDx: 0.5)
          .record()
          .repeat(2, key: 'row')
          .repeat(1)
          .build();

      expect(points.map((point) => point.x), orderedEquals([0.0, 1.0, 0.0, 1.5, 0.0, 1.5]));
      expect(points.map((point) => (point.key! as SeatKey).area), orderedEquals([null, null, 'business', 'business', 'business', 'business']));
      expect(points.map((point) => (point.key! as SeatKey).row), orderedEquals([1, 1, 2, 2, 3, 3]));
    });

    test('record and repeat report invalid block usage', () {
      expect(() => SeatsBuilder().repeat(1), throwsStateError);
      expect(() => SeatsBuilder().repeat(1, key: 'missing'), throwsStateError);
      expect(() => SeatsBuilder().saveRecord(key: 'missing'), throwsStateError);
      expect(() => SeatsBuilder().record().seat().build(), throwsStateError);
      expect(() => SeatsBuilder().record().repeat(-1), throwsArgumentError);

      final stored = SeatsBuilder().record().seat().saveRecord(key: 'row').record().seat();
      expect(() => stored.saveRecord(key: 'row'), throwsArgumentError);
      expect(stored.saveRecord(key: 'other').repeat(1, key: 'other').build(), hasLength(1));
      expect(SeatsBuilder().record().seat().saveRecord(key: '').repeat(1, key: '').build(), hasLength(1));
    });

    test('saveState restores all state without rewinding the cursor', () {
      const originalData = _FirstData('original');
      const changedData = _SecondData('changed');
      final points = SeatsBuilder(
        gapDx: 0.25,
        gapDy: 0.5,
        area: 'economy',
        tags: {_SeatTag.vip},
        data: const {_FirstData: originalData},
      )
          .saveState()
          .gap(gapDx: 1.0, gapDy: 2.0)
          .area('business')
          .tags({_SeatTag.window})
          .data(const {_SecondData: changedData})
          .seat()
          .restoreState()
          .seat()
          .nextRow()
          .seat()
          .build();

      expect(points.map((point) => point.x), orderedEquals([0.0, 1.25, 0.0]));
      expect(points.map((point) => point.y), orderedEquals([0.0, 0.0, 1.5]));
      expect(points.map((point) => (point.key! as SeatKey).column), orderedEquals([1, 2, 1]));
      expect(points.map((point) => (point.key! as SeatKey).area), orderedEquals(['business', 'economy', 'economy']));
      expect((points[0].key! as SeatKey).tags, equals({_SeatTag.window}));
      expect((points[1].key! as SeatKey).tags, equals({_SeatTag.vip}));
      expect(points[0].of<_FirstData>(), isNull);
      expect(points[0].of<_SecondData>(), same(changedData));
      expect(points[1].of<_FirstData>(), same(originalData));
      expect(points[1].of<_SecondData>(), isNull);
    });

    test('saveState exclusions and saveOnlyState selections restore only included fields', () {
      const originalData = _FirstData('original');
      const changedData = _SecondData('changed');
      final points = SeatsBuilder(gapDx: 0.1, area: 'base', tags: {_SeatTag.vip}, data: const {_FirstData: originalData})
          .saveState(key: 'exceptArea', area: false)
          .gap(gapDx: 0.8)
          .area('changed')
          .tags({_SeatTag.window})
          .data(const {_SecondData: changedData})
          .restoreState('exceptArea')
          .seat()
          .seat()
          .saveOnlyState(key: 'areaOnly', area: true)
          .gap(gapDx: 0.9)
          .area('final')
          .tags({_SeatTag.aisle})
          .data(const {_SecondData: changedData})
          .restoreState('areaOnly')
          .nextRow()
          .seat()
          .seat()
          .build();

      expect(points.map((point) => point.x), orderedEquals([0.0, 1.1, 0.0, 1.9]));
      expect(points.map((point) => (point.key! as SeatKey).area), everyElement('changed'));
      expect((points[0].key! as SeatKey).tags, equals({_SeatTag.vip}));
      expect(points[0].of<_FirstData>(), same(originalData));
      expect((points[2].key! as SeatKey).tags, equals({_SeatTag.aisle}));
      expect(points[2].of<_SecondData>(), same(changedData));
    });

    test('empty saveOnlyState is a restorable no-op', () {
      final points = SeatsBuilder(area: 'before')
          .saveOnlyState()
          .area('after')
          .restoreState()
          .seat()
          .saveOnlyState(key: 'empty')
          .area('last')
          .restoreState('empty')
          .seat()
          .build();

      expect(points.map((point) => (point.key! as SeatKey).area), orderedEquals(['after', 'last']));
    });

    test('anonymous state snapshots are LIFO and named snapshots are reusable', () {
      final points = SeatsBuilder(area: 'a')
          .saveState()
          .area('b')
          .saveState()
          .area('c')
          .restoreState()
          .seat()
          .restoreState()
          .seat()
          .saveState(key: 'a')
          .area('d')
          .restoreState('a')
          .seat()
          .area('e')
          .restoreState('a')
          .seat()
          .build();

      expect(points.map((point) => (point.key! as SeatKey).area), orderedEquals(['b', 'a', 'a', 'a']));
    });

    test('named state saves overwrite during saved-record replay and use a separate key namespace', () {
      final points = SeatsBuilder()
          .record()
          .saveState(key: 'shared')
          .area('inside')
          .saveRecord(key: 'shared')
          .area('first')
          .repeat(1, key: 'shared')
          .area('second')
          .repeat(1, key: 'shared')
          .restoreState('shared')
          .seat()
          .build();

      expect((points.single.key! as SeatKey).area, equals('second'));
    });

    test('state restore failures happen during build and builds have independent state stacks', () {
      expect(() => SeatsBuilder().restoreState().build(), throwsStateError);
      expect(() => SeatsBuilder().restoreState('missing').build(), throwsStateError);

      final builder = SeatsBuilder(area: 'base').saveState().area('changed').restoreState().seat();
      expect((builder.build().single.key! as SeatKey).area, equals('base'));
      expect((builder.build().single.key! as SeatKey).area, equals('base'));
    });

    test('builder data is replaced while call data overlays it by type', () {
      const baseFirst = _FirstData('base first');
      const baseSecond = _SecondData('base second');
      const overrideFirst = _FirstData('override first');
      const nextFirst = _FirstData('next first');
      final builder = SeatsBuilder(data: const {_FirstData: baseFirst, _SecondData: baseSecond})
          .seat(data: const {_FirstData: overrideFirst})
          .data(const {_FirstData: nextFirst})
          .seat(data: const {_FirstData: null});
      final points = builder.build();

      expect(points[0].of<_FirstData>(), same(overrideFirst));
      expect(points[0].of<_SecondData>(), same(baseSecond));
      expect(points[1].data.containsKey(_FirstData), isTrue);
      expect(points[1].of<_FirstData>(), isNull);
      expect(points[1].data.containsKey(_SecondData), isFalse);
    });

    test('recorded tags and metadata are isolated from later input mutations', () {
      final tags = <Object>{_SeatTag.vip};
      final data = <Type, IDataPointData?>{_FirstData: const _FirstData('first')};
      final builder = SeatsBuilder().seat(tags: tags, data: data);
      tags.add(_SeatTag.window);
      data[_FirstData] = const _FirstData('changed');
      final point = builder.build().single;

      expect((point.key! as SeatKey).tags, equals({_SeatTag.vip}));
      expect(point.of<_FirstData>()?.value, equals('first'));
    });

    test('changing defaults affects only subsequently interpreted seat actions', () {
      final points = SeatsBuilder(area: 'first', tags: {_SeatTag.vip})
          .seat()
          .area('second')
          .tags({_SeatTag.window})
          .seat()
          .area(null)
          .tags({})
          .seat()
          .build();

      expect((points[0].key! as SeatKey).area, equals('first'));
      expect((points[0].key! as SeatKey).tags, equals({_SeatTag.vip}));
      expect((points[1].key! as SeatKey).area, equals('second'));
      expect((points[1].key! as SeatKey).tags, equals({_SeatTag.window}));
      expect((points[2].key! as SeatKey).area, isNull);
      expect((points[2].key! as SeatKey).tags, isEmpty);
    });

    test('build returns independent unmodifiable snapshots', () {
      final builder = SeatsBuilder().seat();
      final first = builder.build();
      builder.seat();
      final second = builder.build();

      expect(first.length, equals(1));
      expect(second.length, equals(2));
      expect(first.single, isNot(same(second.first)));
      expect(() => first.add(const DataPoint(x: 0.0, dy: 0.0)), throwsUnsupportedError);
    });

    test('rejects invalid dimensions, gaps, values, and counts when supplied', () {
      expect(() => SeatsBuilder(x: double.nan), throwsArgumentError);
      expect(() => SeatsBuilder(y: double.infinity), throwsArgumentError);
      expect(() => SeatsBuilder(seatDx: 0.0), throwsArgumentError);
      expect(() => SeatsBuilder(rowDy: -1.0), throwsArgumentError);
      expect(() => SeatsBuilder(gapDx: -1.0), throwsArgumentError);
      expect(() => SeatsBuilder(gapDy: double.nan), throwsArgumentError);

      final builder = SeatsBuilder();
      expect(() => builder.seat(z: double.nan), throwsArgumentError);
      expect(() => builder.seats(-1), throwsArgumentError);
      expect(() => builder.skip(-1), throwsArgumentError);
      expect(() => builder.nextRow(-1), throwsArgumentError);
      expect(() => builder.repeat(-1), throwsArgumentError);
      expect(() => builder.gap(gapDx: -1.0), throwsArgumentError);
      expect(() => builder.gap(gapDy: double.infinity), throwsArgumentError);
      expect(builder.seats(0).skip(0).nextRow(0).build(), isEmpty);
    });
  });

  group('DataPointPipeline seats', () {

    test('applies set selector, exact keys, and predicate as AND filters', () {
      final selectedKey = SeatKey(label: '1B', row: 1, column: 2, area: 'main');
      const style = CircleDataPointStyle(radius: Px(4.0), color: Colors.blue);
      final selectedKeys = <SeatKey>{SeatKey(label: 'stored-id', row: 1, column: 2, area: 'main', tags: {_SeatTag.window})};
      final pipeline = DataPointPipeline().seats(
        selector: SeatSelector(labels: {'1B', '1C'}, rows: {1, 3}, areas: {'main'}, tags: {{_SeatTag.vip}, {_SeatTag.accessible}}),
        keys: selectedKeys,
        predicate: (point, key) => point.x > 0.0 && key.column == 2,
        style: style,
      );
      selectedKeys.clear();
      final input = [
        DataPoint(x: 0.0, dy: 0.0, key: SeatKey(label: '1A', row: 1, column: 1, area: 'main', tags: {_SeatTag.vip})),
        DataPoint(x: 1.0, dy: 0.0, key: SeatKey(label: '1B', row: 1, column: 2, area: 'main', tags: {_SeatTag.vip, _SeatTag.aisle})),
        DataPoint(x: 2.0, dy: 0.0, key: SeatKey(label: '2B', row: 2, column: 2, area: 'main', tags: {_SeatTag.vip})),
        const DataPoint(x: 3.0, dy: 0.0, key: 'not a seat'),
      ];
      final out = pipeline.build(input);

      expect(selectedKey, equals(input[1].key));
      expect(out[0], same(input[0]));
      expect(out[1].style, same(style));
      expect(out[2], same(input[2]));
      expect(out[3], same(input[3]));
    });

    test('decorates every seat, preserves metadata, and replaces extent only when supplied', () {
      const metadata = _FirstData('metadata');
      const oldExtent = ChartInsets(left: Px(1.0));
      const newExtent = ChartInsets(right: Px(2.0));
      const baseStyle = CircleDataPointStyle(radius: Px(3.0), color: Colors.blue);
      const finalStyle = CircleDataPointStyle(radius: Px(5.0), color: Colors.red);
      final key = SeatKey(label: '1A', row: 1, column: 1);
      final pipeline = DataPointPipeline()
          .seats(style: baseStyle)
          .seats(keys: {key}, style: finalStyle, extent: newExtent);
      final out = pipeline.build([
        DataPoint(x: 0.0, dy: 0.0, key: key, data: const {_FirstData: metadata, IDataPointExtent: oldExtent}),
        DataPoint(x: 1.0, dy: 0.0, key: SeatKey(label: '1B', row: 1, column: 2), data: const {IDataPointExtent: oldExtent}),
      ]);

      expect(out[0].style, same(finalStyle));
      expect(out[0].extent, same(newExtent));
      expect(out[0].of<_FirstData>(), same(metadata));
      expect(out[1].style, same(baseStyle));
      expect(out[1].extent, same(oldExtent));
    });

    test('does not depend on z and integrates repeated rows with one scatter series', () {
      const style = CircleDataPointStyle(radius: Px(3.0), color: Colors.blue);
      final raw = SeatsBuilder().record().seats(2).nextRow().repeat(2).build();
      final input = [raw[0].copyWith(z: double.nan), ...raw.skip(1)];
      final points = DataPointPipeline().seats(style: style).build(input);
      final chart = LineData.scatter(points: points);

      expect(points.length, equals(4));
      expect(points.every((point) => identical(point.style, style)), isTrue);
      expect(points.first.z.isNaN, isTrue);
      expect(chart.line, same(points));
      expect(chart.lineType, isA<ScatterLineData>());
    });
  });
}
