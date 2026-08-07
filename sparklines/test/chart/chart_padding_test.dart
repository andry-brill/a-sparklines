import 'dart:ui';

import 'package:any_sparklines/any_sparklines.dart';
import 'package:any_sparklines/chart/chart_padding.dart';
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

class _RecordingChartData implements ISparklinesData {
  @override final IChartRenderer renderer;

  const _RecordingChartData(this.renderer);

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

void main() {
  group('ChartPadding value', () {
    test('defaults to empty', () {
      expect(const ChartPadding().isEmpty, isTrue);
      expect(const ChartPadding().left, isNull);
      expect(const ChartPadding().top, isNull);
      expect(const ChartPadding().right, isNull);
      expect(const ChartPadding().bottom, isNull);
      expect(const SparklinesChart(charts: []).padding, const ChartPadding());
    });

    test('has value equality', () {
      expect(const ChartPadding(left: Px(10)), const ChartPadding(left: Px(10)));
      expect(const ChartPadding(left: Px(10)), isNot(const ChartPadding(right: Px(10))));
      expect(const ChartPadding(left: Px(10)).hashCode, const ChartPadding(left: Px(10)).hashCode);
    });
  });

  group('padding matrix', () {
    test('maps the preliminary viewport into asymmetric padding', () {
      final preliminary = const RelativeLayout.normalized().transform(_dimensions);
      final padded = paddedChartMatrix(
        preliminary,
        _dimensions,
        const ChartPadding(left: Px(10), top: Px(5), right: Px(20), bottom: Px(15)),
      );
      final transform = ChartTransform(dimensions: _dimensions, pathTransform: padded);

      expect(transform.xy(0, 0), const Offset(10, 65));
      expect(transform.xy(1, 1), const Offset(80, 5));
    });

    test('resolves viewport and data units with the preliminary transform', () {
      final preliminary = const RelativeLayout.normalized().transform(_dimensions);
      final padded = paddedChartMatrix(
        preliminary,
        _dimensions,
        const ChartPadding(left: Dx(0.1), top: Dy(0.1), right: Vw(10), bottom: Vh(10)),
      );
      final transform = ChartTransform(dimensions: _dimensions, pathTransform: padded);

      expect(transform.xy(0, 0), const Offset(10, 72));
      expect(transform.xy(1, 1), const Offset(90, 8));
      expect(transform.length(const Dx(0.1)), closeTo(8, 1e-10));
      expect(transform.length(const Dy(0.1)), closeTo(6.4, 1e-10));
    });

    test('collapses x when horizontal padding consumes the viewport', () {
      final preliminary = const RelativeLayout.normalized().transform(_dimensions);
      final padded = paddedChartMatrix(
        preliminary,
        _dimensions,
        const ChartPadding(left: Px(70), right: Px(30)),
      );
      final transform = ChartTransform(dimensions: _dimensions, pathTransform: padded);

      expect(transform.xy(0, 0).dx, 70);
      expect(transform.xy(1, 1).dx, 70);
    });

    test('collapses y when vertical padding consumes the viewport', () {
      final preliminary = const RelativeLayout.normalized().transform(_dimensions);
      final padded = paddedChartMatrix(
        preliminary,
        _dimensions,
        const ChartPadding(top: Px(50), bottom: Px(40)),
      );
      final transform = ChartTransform(dimensions: _dimensions, pathTransform: padded);

      expect(transform.xy(0, 0).dy, 50);
      expect(transform.xy(1, 1).dy, 50);
    });

    test('clamps negative padding to zero', () {
      final preliminary = const RelativeLayout.normalized().transform(_dimensions);
      final padded = paddedChartMatrix(
        preliminary,
        _dimensions,
        const ChartPadding(left: Px(-10), top: Px(-10)),
      );
      final transform = ChartTransform(dimensions: _dimensions, pathTransform: padded);

      expect(transform.xy(0, 0), const Offset(0, 80));
      expect(transform.xy(1, 1), const Offset(100, 0));
    });
  });

  group('painter padding', () {
    test('empty padding preserves the preliminary transform', () {
      final renderer = _RecordingChartRenderer();
      final painter = SparklinesPainter(
        charts: [_RecordingChartData(renderer)],
        defaultLayout: const RelativeLayout.normalized(),
        defaultCrop: false,
        width: 100,
        height: 80,
      );

      painter.paint(_canvas(), const Size(100, 80));

      expect(renderer.start, const Offset(0, 80));
      expect(renderer.end, const Offset(100, 0));
    });

    test('applies padding to the chart transform', () {
      final renderer = _RecordingChartRenderer();
      final painter = SparklinesPainter(
        charts: [_RecordingChartData(renderer)],
        defaultLayout: const RelativeLayout.normalized(),
        defaultCrop: false,
        padding: const ChartPadding(left: Px(10), top: Px(5), right: Px(20), bottom: Px(15)),
        width: 100,
        height: 80,
      );

      painter.paint(_canvas(), const Size(100, 80));

      expect(renderer.start, const Offset(10, 65));
      expect(renderer.end, const Offset(80, 5));
    });

    test('padding changes trigger repaint', () {
      final renderer = _RecordingChartRenderer();
      final oldPainter = SparklinesPainter(
        charts: [_RecordingChartData(renderer)],
        defaultLayout: const RelativeLayout.normalized(),
        defaultCrop: false,
        width: 100,
        height: 80,
      );
      final newPainter = SparklinesPainter(
        charts: [_RecordingChartData(renderer)],
        defaultLayout: const RelativeLayout.normalized(),
        defaultCrop: false,
        padding: const ChartPadding(left: Px(10)),
        width: 100,
        height: 80,
      );

      expect(newPainter.shouldRepaint(oldPainter), isTrue);
    });
  });
}
