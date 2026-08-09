import 'package:any_sparklines/any_sparklines.dart';
import 'package:any_sparklines/chart/sparklines_painter.dart';
import 'package:any_sparklines/data/layout_data.dart';
import 'package:any_sparklines/interfaces/length_value.dart' show Lp;
import 'package:test/test.dart';

ChartTransform _transform({
  IChartLayout layout = const RelativeLayout(
    minX: -10,
    maxX: 10,
    minY: -2,
    maxY: 2,
  ),
  double width = 200,
  double height = 80,
}) {
  final dimensions = LayoutData(
    minX: -10,
    maxX: 10,
    minY: -2,
    maxY: 2,
    width: width,
    height: height,
  );
  return ChartTransform(
    dimensions: dimensions,
    pathTransform: layout.transform(dimensions),
  );
}

final class Vmean implements ILengthValue {
  final double percentage;

  const Vmean(this.percentage);

  @override
  double resolve(ILengthContext context) {
    return (context.viewportWidth + context.viewportHeight) / 2 * percentage / 100;
  }
}

void main() {
  group('built-in length values', () {
    test('resolve pixels and CSS-style viewport percentages', () {
      final transform = _transform();

      expect(transform.length(const Px(7)), 7);
      expect(transform.length(const Vw(1)), 2);
      expect(transform.length(const Vh(2.5)), 2);
      expect(transform.length(const Vmin(10)), 8);
      expect(transform.length(const Vmax(10)), 20);
    });

    test('resolve data-axis magnitudes through a relative matrix', () {
      final transform = _transform();

      expect(transform.length(const Dx(2)), closeTo(20, 1e-10));
      expect(transform.length(const Dy(1)), closeTo(20, 1e-10));
      expect(transform.length(const Dx(-2)), closeTo(20, 1e-10));
    });

    test('data-axis magnitudes are 1:1 under absolute layout', () {
      final transform = _transform(layout: const AbsoluteLayout());

      expect(transform.length(const Dx(3)), closeTo(3, 1e-10));
      expect(transform.length(const Dy(4)), closeTo(4, 1e-10));
    });

    test('use logical dimensions supplied after a rotation swap', () {
      final chart = LineData(
        rotation: ChartRotation.d90,
        line: const [DataPoint(x: 0, dy: 0), DataPoint(x: 1, dy: 1)],
      );
      final painter = SparklinesPainter(
        charts: [chart],
        defaultLayout: const RelativeLayout.normalized(),
        defaultCrop: false,
        width: 200,
        height: 100,
      );
      final dimensions = painter.layoutData(chart);
      final layout = const RelativeLayout.normalized();
      final transform = ChartTransform(
        dimensions: dimensions,
        pathTransform: layout.transform(dimensions),
      );

      expect(dimensions.width, 100);
      expect(dimensions.height, 200);
      expect(transform.length(const Vw(1)), 1);
      expect(transform.length(const Vh(1)), 2);
    });

    test('support custom user-defined units without a type switch', () {
      final transform = _transform();

      expect(transform.length(const Vmean(10)), 14);
    });

    test('provide value equality for built-in units', () {
      expect(const Px(2), const Px(2));
      expect(const Px(2), isNot(const Dx(2)));
      expect(const Vw(1).hashCode, const Vw(1).hashCode);
      expect(const Vmin(2), const Vmin(2));
      expect(const Vmin(2), isNot(const Vmax(2)));
    });

    test('shared relative layouts still resolve from every data series', () {
      const layout = RelativeLayout.full();
      final resolved = layout.resolve(const [
        LayoutData(
          minX: -2,
          maxX: 3,
          minY: 1,
          maxY: 4,
          width: 200,
          height: 100,
        ),
        LayoutData(
          minX: -5,
          maxX: 2,
          minY: -3,
          maxY: 2,
          width: 200,
          height: 100,
        ),
      ]) as RelativeLayout;

      expect(resolved.minX, -5);
      expect(resolved.maxX, 3);
      expect(resolved.minY, -3);
      expect(resolved.maxY, 4);
    });
  });

  group('deferred length interpolation', () {
    test('resolve different units in the current context before lerping', () {
      final value = ILengthValue.lerp(const Px(10), const Vw(10), 0.5)!;

      expect(_transform().length(value), 15);
      expect(_transform(width: 400).length(value), 25);
    });

    test('treat a missing in-progress endpoint as zero pixels', () {
      final appearing = ILengthValue.lerp(null, const Px(10), 0.5)!;
      final disappearing = ILengthValue.lerp(const Vw(10), null, 0.5)!;

      expect(_transform().length(appearing), 5);
      expect(_transform().length(disappearing), 10);
    });

    test('retain exact nullable endpoints', () {
      const from = Px(2);
      const to = Vw(3);

      expect(ILengthValue.lerp(from, to, 0), same(from));
      expect(ILengthValue.lerp(from, to, 1), same(to));
      expect(ILengthValue.lerp(null, to, 0), isNull);
      expect(ILengthValue.lerp(from, null, 1), isNull);
    });

    test('Lp has immutable value equality', () {
      expect(
        const Lp(Px(1), Vw(2), 0.5),
        const Lp(Px(1), Vw(2), 0.5),
      );
      expect(
        const Lp(Px(1), Vw(2), 0.5),
        isNot(const Lp(Px(1), Vw(2), 0.75)),
      );
    });
  });
}
