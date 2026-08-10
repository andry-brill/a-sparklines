import 'dart:collection';
import 'dart:ui';

import 'package:any_sparklines/any_sparklines.dart';
import 'package:any_sparklines/chart/chart_insets.dart';
import 'package:any_sparklines/chart/sparklines_painter.dart';
import 'package:any_sparklines/data/layout_data.dart';
import 'package:test/test.dart';

const _dimensions = LayoutData(
  minX: 0,
  maxX: 1,
  minY: 0,
  maxY: 1,
  width: 100,
  height: 80,
);

ChartTransform _transform() => ChartTransform(
  dimensions: _dimensions,
  pathTransform: const RelativeLayout.normalized().transform(_dimensions),
);

Canvas _canvas() => Canvas(PictureRecorder());

class _RecordingChartRenderer implements IChartRenderer {
  Offset? start;
  Offset? end;

  @override
  void render(Canvas canvas, ChartTransform transform, ISparklinesData data) {
    start = transform.xy(0, 0);
    end = transform.xy(1, 1);
  }
}

class _RecordingChartData with IterableMixin<DataPoint> implements ISparklinesData {
  @override final IChartRenderer renderer;
  @override final ChartInsets padding;
  final Iterable<DataPoint> points;
  @override final bool supportsPointExtents;

  const _RecordingChartData(
    this.renderer, {
    this.padding = const ChartInsets(),
    this.points = const [],
    this.supportsPointExtents = true,
  });

  @override Iterator<DataPoint> get iterator => points.iterator;
  @override bool get visible => true;
  @override IChartLayout? get layout => null;
  @override ChartRotation get rotation => ChartRotation.d0;
  @override ChartFlip get flip => ChartFlip.none;
  @override Offset get origin => Offset.zero;
  @override bool? get crop => null;
  @override double get minX => 0;
  @override double get maxX => 1;
  @override double get minY => 0;
  @override double get maxY => 1;
  @override bool shouldRepaint(ISparklinesData other) => other != this;
  @override ISparklinesData lerpTo(ISparklinesData next, double t) => next;
}

SparklinesPainter _painter(
  _RecordingChartRenderer renderer, {
  ChartInsets padding = const ChartInsets(),
  ChartInsets localPadding = const ChartInsets(),
  Iterable<DataPoint> points = const [],
  IChartLayout layout = const RelativeLayout.normalized(),
  double width = 100,
  double height = 80,
  bool supportsPointExtents = true,
}) => SparklinesPainter(
  charts: [_RecordingChartData(renderer, padding: localPadding, points: points, supportsPointExtents: supportsPointExtents)],
  defaultLayout: layout,
  defaultCrop: false,
  padding: padding,
  width: width,
  height: height,
);

void main() {
  group('ChartInsets value', () {
    test('defaults to empty and has value equality', () {
      expect(const ChartInsets().isEmpty, isTrue);
      expect(const ChartInsets().left, isNull);
      expect(const ChartInsets().top, isNull);
      expect(const ChartInsets().right, isNull);
      expect(const ChartInsets().bottom, isNull);
      expect(const ChartInsets(left: Px(10)), const ChartInsets(left: Px(10)));
      expect(const ChartInsets(left: Px(10)), isNot(const ChartInsets(right: Px(10))));
      expect(const ChartInsets(left: Px(10)).hashCode, const ChartInsets(left: Px(10)).hashCode);
      expect(const SparklinesChart(charts: []).padding, const ChartInsets());
    });

    test('named constructors map values to all, horizontal, or vertical sides', () {
      expect(const ChartInsets.all(Px(10)), const ChartInsets(left: Px(10), top: Px(10), right: Px(10), bottom: Px(10)));
      expect(const ChartInsets.horizontal(Px(10)), const ChartInsets(left: Px(10), right: Px(10)));
      expect(const ChartInsets.vertical(Px(10)), const ChartInsets(top: Px(10), bottom: Px(10)));
    });

    test('interpolates lengths and works as data-point extent metadata', () {
      const from = ChartInsets(left: Px(0), top: Vh(0));
      const to = ChartInsets(left: Px(10), top: Vh(20));
      final interpolated = from.lerp(to, 0.5);
      const point = DataPoint(
        x: 0,
        dy: 0,
        data: {IDataPointExtent: ChartInsets(left: Px(4))},
      );

      expect(interpolated.left!.resolve(_transform()), 5);
      expect(interpolated.top!.resolve(_transform()), 8);
      expect(point.extent, const ChartInsets(left: Px(4)));
    });
  });

  group('insets matrix', () {
    test('maps the preliminary viewport into asymmetric insets', () {
      final preliminary = const RelativeLayout.normalized().transform(_dimensions);
      final matrix = insetChartMatrix(
        preliminary,
        _dimensions,
        const ResolvedChartInsets(left: 10, top: 5, right: 20, bottom: 15),
      );
      final transform = ChartTransform(dimensions: _dimensions, pathTransform: matrix);

      expect(transform.xy(0, 0), const Offset(10, 65));
      expect(transform.xy(1, 1), const Offset(80, 5));
    });

    test('uses weighted collapse when horizontal insets exceed the viewport', () {
      const dimensions = LayoutData(minX: 0, maxX: 1, minY: 0, maxY: 1, width: 10, height: 10);
      final preliminary = const RelativeLayout.normalized().transform(dimensions);
      final matrix = insetChartMatrix(
        preliminary,
        dimensions,
        const ResolvedChartInsets(left: 10, right: 40),
      );
      final transform = ChartTransform(dimensions: dimensions, pathTransform: matrix);

      expect(transform.xy(0, 0).dx, 2);
      expect(transform.xy(1, 1).dx, 2);
    });

    test('uses weighted collapse when vertical insets equal the viewport', () {
      const dimensions = LayoutData(minX: 0, maxX: 1, minY: 0, maxY: 1, width: 10, height: 10);
      final preliminary = const RelativeLayout.normalized().transform(dimensions);
      final matrix = insetChartMatrix(
        preliminary,
        dimensions,
        const ResolvedChartInsets(top: 3, bottom: 7),
      );
      final transform = ChartTransform(dimensions: dimensions, pathTransform: matrix);

      expect(transform.xy(0, 0).dy, 3);
      expect(transform.xy(1, 1).dy, 3);
    });

    test('clamps negative and invalid resolved lengths to zero', () {
      final resolved = resolveChartInsets(
        _transform(),
        const ChartInsets(left: Px(-10), top: Px(double.nan), right: Px(double.infinity)),
      );

      expect(resolved.left, 0);
      expect(resolved.top, 0);
      expect(resolved.right, 0);
    });
  });

  group('painter fitting', () {
    test('preserves the preliminary transform without any insets', () {
      final renderer = _RecordingChartRenderer();
      final painter = _painter(renderer);

      painter.paint(_canvas(), const Size(100, 80));

      expect(renderer.start, const Offset(0, 80));
      expect(renderer.end, const Offset(100, 0));
    });

    test('applies global padding', () {
      final renderer = _RecordingChartRenderer();
      final painter = _painter(
        renderer,
        padding: const ChartInsets(left: Px(10), top: Px(5), right: Px(20), bottom: Px(15)),
      );

      painter.paint(_canvas(), const Size(100, 80));

      expect(renderer.start, const Offset(10, 65));
      expect(renderer.end, const Offset(80, 5));
    });

    test('applies local padding', () {
      final renderer = _RecordingChartRenderer();
      final painter = _painter(
        renderer,
        localPadding: const ChartInsets(left: Px(7), top: Px(3), right: Px(11), bottom: Px(5)),
      );

      painter.paint(_canvas(), const Size(100, 80));

      expect(renderer.start, const Offset(7, 75));
      expect(renderer.end, const Offset(89, 3));
    });

    test('automatically applies point extent overflow', () {
      final renderer = _RecordingChartRenderer();
      final painter = _painter(
        renderer,
        points: const [
          DataPoint(x: 0, y: 0.5, dy: 0, data: {IDataPointExtent: ChartInsets(left: Px(6))}),
          DataPoint(x: 1, y: 0.5, dy: 0, data: {IDataPointExtent: ChartInsets(right: Px(9))}),
        ],
      );

      painter.paint(_canvas(), const Size(100, 80));

      expect(renderer.start, const Offset(6, 80));
      expect(renderer.end, const Offset(91, 0));
    });

    test('adds global, local, and point extent insets', () {
      final renderer = _RecordingChartRenderer();
      final painter = _painter(
        renderer,
        padding: const ChartInsets(left: Px(3)),
        localPadding: const ChartInsets(left: Px(4)),
        points: const [
          DataPoint(x: 0, dy: 0, data: {IDataPointExtent: ChartInsets(left: Px(5))}),
        ],
      );

      painter.paint(_canvas(), const Size(100, 80));

      expect(renderer.start!.dx, 12);
      expect(renderer.end!.dx, 100);
    });

    test('uses actual position overflow instead of the largest extent', () {
      final renderer = _RecordingChartRenderer();
      final painter = _painter(
        renderer,
        points: const [
          DataPoint(x: 0, dy: 0, data: {IDataPointExtent: ChartInsets(left: Px(5))}),
          DataPoint(x: 0.2, dy: 0, data: {IDataPointExtent: ChartInsets(left: Px(20))}),
        ],
      );

      painter.paint(_canvas(), const Size(100, 80));

      expect(renderer.start!.dx, 5);
      expect(renderer.end!.dx, 100);
    });

    test('resolves mixed units through the preliminary transform once', () {
      final renderer = _RecordingChartRenderer();
      final painter = _painter(
        renderer,
        points: const [
          DataPoint(x: 0, y: 0.5, dy: 0, data: {IDataPointExtent: ChartInsets(left: Dx(0.1))}),
          DataPoint(x: 1, y: 0.5, dy: 0, data: {IDataPointExtent: ChartInsets(right: Vw(10))}),
          DataPoint(x: 0.5, y: 1, dy: 0, data: {IDataPointExtent: ChartInsets(top: Dy(0.1))}),
          DataPoint(x: 0.5, y: 0, dy: 0, data: {IDataPointExtent: ChartInsets(bottom: Vh(10))}),
        ],
      );

      painter.paint(_canvas(), const Size(100, 80));

      expect(renderer.start, const Offset(10, 72));
      expect(renderer.end, const Offset(90, 8));
    });

    test('points without extent metadata do not add fitting', () {
      final renderer = _RecordingChartRenderer();
      final painter = _painter(
        renderer,
        points: const [DataPoint(x: 0, dy: 0), DataPoint(x: 1, y: 1, dy: 0)],
      );

      painter.paint(_canvas(), const Size(100, 80));

      expect(renderer.start, const Offset(0, 80));
      expect(renderer.end, const Offset(100, 0));
    });

    test('point extents do not add fitting when the chart does not support them', () {
      final renderer = _RecordingChartRenderer();
      final painter = _painter(
        renderer,
        supportsPointExtents: false,
        points: const [DataPoint(x: 0, dy: 0, data: {IDataPointExtent: ChartInsets(left: Px(20))})],
      );

      painter.paint(_canvas(), const Size(100, 80));

      expect(renderer.start, const Offset(0, 80));
      expect(renderer.end, const Offset(100, 0));
    });

    test('shared layouts combine all chart requirements', () {
      final first = _RecordingChartRenderer();
      final second = _RecordingChartRenderer();
      final painter = SparklinesPainter(
        charts: [
          _RecordingChartData(
            first,
            padding: const ChartInsets(left: Px(4)),
            points: const [DataPoint(x: 0, dy: 0, data: {IDataPointExtent: ChartInsets(left: Px(3))})],
          ),
          _RecordingChartData(
            second,
            padding: const ChartInsets(right: Px(5)),
            points: const [DataPoint(x: 1, dy: 0, data: {IDataPointExtent: ChartInsets(right: Px(7))})],
          ),
        ],
        defaultLayout: const RelativeLayout.normalized(),
        defaultCrop: false,
        padding: const ChartInsets(top: Px(2)),
        width: 100,
        height: 80,
      );

      painter.paint(_canvas(), const Size(100, 80));

      expect(first.start, const Offset(7, 80));
      expect(first.end, const Offset(88, 2));
      expect(second.start, first.start);
      expect(second.end, first.end);
    });

    test('explicit layout headroom prevents unnecessary extent fitting', () {
      final renderer = _RecordingChartRenderer();
      final painter = _painter(
        renderer,
        layout: const RelativeLayout(minX: -1, maxX: 1, minY: 0, maxY: 1),
        points: const [
          DataPoint(x: 0, dy: 0, data: {IDataPointExtent: ChartInsets(left: Px(20), right: Px(20))}),
        ],
      );

      painter.paint(_canvas(), const Size(100, 80));

      expect(renderer.start, const Offset(50, 80));
      expect(renderer.end, const Offset(100, 0));
    });

    test('padding changes trigger repaint', () {
      final renderer = _RecordingChartRenderer();
      final oldPainter = _painter(renderer);
      final newPainter = _painter(renderer, padding: const ChartInsets(left: Px(10)));

      expect(newPainter.shouldRepaint(oldPainter), isTrue);
    });
  });

  group('chart data padding and iteration', () {
    const points = [DataPoint(x: 0, dy: 1)];
    const start = ChartInsets(left: Px(0));
    const end = ChartInsets(left: Px(10));

    test('line and scatter propagate padding and points', () {
      const line = LineData(line: points, padding: start);
      const scatter = LineData.scatter(points: points, padding: end);
      final copied = line.copyWith(padding: end);
      final interpolated = line.lerpTo(copied, 0.5) as LineData;

      expect(line, orderedEquals(line.line));
      expect(scatter, orderedEquals(scatter.line));
      expect(line.supportsPointExtents, isTrue);
      expect(scatter.supportsPointExtents, isTrue);
      expect(copied.padding, end);
      expect(copied.shouldRepaint(line), isTrue);
      expect(interpolated.padding.left!.resolve(_transform()), 5);
    });

    test('bar propagates padding and points', () {
      const data = BarData(bars: points, padding: start);
      final copied = data.copyWith(padding: end);
      final interpolated = data.lerpTo(copied, 0.5) as BarData;

      expect(data, orderedEquals(data.bars));
      expect(data.supportsPointExtents, isTrue);
      expect(copied.padding, end);
      expect(copied.shouldRepaint(data), isTrue);
      expect(interpolated.padding.left!.resolve(_transform()), 5);
    });

    test('pie constructors propagate padding and points', () {
      final data = PieData(pies: points, padding: start);
      final clockwise = PieData.clockwise(pies: points, padding: end);
      final copied = data.copyWith(padding: end);
      final interpolated = data.lerpTo(copied, 0.5) as PieData;

      expect(data, orderedEquals(data.pies));
      expect(data.supportsPointExtents, isTrue);
      expect(clockwise.padding, end);
      expect(copied.padding, end);
      expect(copied.shouldRepaint(data), isTrue);
      expect(interpolated.padding.left!.resolve(_transform()), 5);
    });

    test('between-line propagates padding and iterates both lines without supporting point extents', () {
      const from = LineData(line: points);
      const toPoints = [DataPoint(x: 1, dy: 2)];
      const to = LineData(line: toPoints);
      const data = BetweenLineData(from: from, to: to, padding: start);
      final copied = data.copyWith(padding: end);
      final interpolated = data.lerpTo(copied, 0.5) as BetweenLineData;

      expect(data, orderedEquals([...points, ...toPoints]));
      expect(data.supportsPointExtents, isFalse);
      expect(copied.padding, end);
      expect(copied.shouldRepaint(data), isTrue);
      expect(interpolated.padding.left!.resolve(_transform()), 5);
    });
  });
}
