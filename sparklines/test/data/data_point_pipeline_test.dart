import 'dart:math';

import 'package:test/test.dart';

import 'package:any_sparklines/data/data_point.dart';
import 'package:any_sparklines/data/data_point_pipeline.dart';


List<DataPoint> pointList(double x, double y, double dy) =>
    [DataPoint(x: x, y: y, dy: dy)];

List<DataPoint> points(List<(double x, double y, double dy)> coords) =>
    coords.map((e) => DataPoint(x: e.$1, y: e.$2, dy: e.$3)).toList();

void main() {
  group('DataPointPipeline', () {

    test('given: no modifiers and one input list, should: return same points as unmodifiable list', () {

      final pipeline = DataPointPipeline();
      final input = points([(0.0, 0.0, 10.0), (1.0, 0.0, -4.0)]);
      final out = pipeline.build(input);

      final actual = out.length;
      final expected = 2;

      expect(actual, equals(expected));
      expect(out[0].x, equals(0.0));
      expect(out[0].y, equals(0.0));
      expect(out[0].dy, equals(10.0));
      expect(out[1].x, equals(1.0));
      expect(out[1].dy, equals(-4.0));
    });

    test('given: empty input and no modifiers, should: return empty list', () {

      final pipeline = DataPointPipeline();
      final input = <DataPoint>[];
      final out = pipeline.build(input);

      final actual = out.length;
      final expected = 0;

      expect(actual, equals(expected));
    });

    test('given: two build() calls then access both, should: return correct list per id', () {

      final pipeline = DataPointPipeline();
      final a = points([(0.0, 0.0, 1.0)]);
      final b = points([(0.0, 0.0, 2.0), (1.0, 0.0, 3.0)]);
      final outA = pipeline.build(a);
      final outB = pipeline.build(b);

      final actualLenA = outA.length;
      final expectedLenA = 1;
      final actualLenB = outB.length;
      final expectedLenB = 2;

      expect(actualLenA, equals(expectedLenA));
      expect(actualLenB, equals(expectedLenB));
      expect(outA[0].dy, equals(1.0));
      expect(outB[0].dy, equals(2.0));
      expect(outB[1].dy, equals(3.0));
    });
  });

  group('StackModifier', () {

    test('given: pipeline.stack(true) and one point, should: leave y at 0 and dy unchanged', () {

      final pipeline = DataPointPipeline().stack(true);
      final input = pointList(2.0, 0.0, 7.0);
      final out = pipeline.build(input);

      final actualY = out[0].y;
      final expectedY = 0.0;
      final actualDy = out[0].dy;
      final expectedDy = 7.0;

      expect(actualY, equals(expectedY));
      expect(actualDy, equals(expectedDy));
    });

    test('given: pipeline.stack(true) and two bars at same x, should: second bar starts at top of first', () {

      final pipeline = DataPointPipeline().stack(true);
      final input = points([(1.0, 0.0, 6.0), (1.0, 0.0, 4.0)]);
      final out = pipeline.build(input);

      final actualFirstY = out[0].y;
      final expectedFirstY = 0.0;
      final actualSecondY = out[1].y;
      final expectedSecondY = 6.0;

      expect(actualFirstY, equals(expectedFirstY));
      expect(actualSecondY, equals(expectedSecondY));
    });

    test('given: pipeline.stack(true) with spacing 1.0 and two bars at same x, should: add spacing between stacked values', () {

      final pipeline = DataPointPipeline(spacing: 1.0).stack(true);
      final input = points([(1.0, 0.0, 6.0), (1.0, 0.0, 4.0)]);
      final out = pipeline.build(input);

      final actualSecondY = out[1].y;
      final expectedSecondY = 7.0;

      expect(actualSecondY, equals(expectedSecondY));
    });

    test('given: pipeline.stack(true) and bars at different x, should: stack independently per x', () {

      final pipeline = DataPointPipeline().stack(true);
      final input = points([(0.0, 0.0, 5.0), (1.0, 0.0, 10.0), (0.0, 0.0, 3.0)]);
      final out = pipeline.build(input);

      final actualThirdY = out[2].y;
      final expectedThirdY = 5.0;

      expect(actualThirdY, equals(expectedThirdY));
    });

    test('given: pipeline.stack(false) and two bars at same x, should: not apply stacking', () {

      final pipeline = DataPointPipeline().stack(false);
      final input = points([(1.0, 0.0, 6.0), (1.0, 0.0, 4.0)]);
      final out = pipeline.build(input);

      final actualSecondY = out[1].y;
      final expectedSecondY = 0.0;

      expect(actualSecondY, equals(expectedSecondY));
    });
  });

  group('NormalizeModifier', () {

    test('given: pipeline.normalize() and empty input, should: return empty list', () {

      final pipeline = DataPointPipeline().normalize(low: 0.0, high: 1.0);
      final input = <DataPoint>[];
      final out = pipeline.build(input);

      final actual = out.length;
      final expected = 0;

      expect(actual, equals(expected));
    });

    test('given: pipeline.normalize() and single point with positive dy, should: scale to fill [0, high]', () {

      final pipeline = DataPointPipeline().normalize(low: 0.0, high: 1.0);
      final input = pointList(0.0, 0.0, 100.0);
      final out = pipeline.build(input);

      final actualDy = out[0].dy;
      final expectedDy = 1.0;

      expect(actualDy, equals(expectedDy));
    });

    test('given: pipeline.normalize() default [0,1] and positive dy only, should: scale to 0..1', () {

      final pipeline = DataPointPipeline().normalize(low: 0.0, high: 1.0);
      final input = points([(0.0, 0.0, 4.0), (1.0, 0.0, 6.0)]);
      final out = pipeline.build(input);

      final actualFirstDy = out[0].dy;
      final actualSecondDy = out[1].dy;
      final expectedFirstDy = 0.4;
      final expectedSecondDy = 0.6;

      expect(actualFirstDy, closeTo(expectedFirstDy, 1e-10));
      expect(actualSecondDy, closeTo(expectedSecondDy, 1e-10));
    });

    test('given: pipeline.normalize(low: 0, high: 1, mid: 0.5) and two equal positive dy, should: keep y unchanged and scale dy into [mid, high]', () {

      final pipeline = DataPointPipeline().normalize(low: 0.0, high: 1.0, mid: 0.5);
      final input = points([(0.0, 0.0, 1.0), (1.0, 0.0, 1.0)]);
      final out = pipeline.build(input);

      expect(out[0].y, equals(0.0));
      expect(out[1].y, equals(0.0));
      expect(out[0].dy, closeTo(0.25, 1e-10));
      expect(out[1].dy, closeTo(0.25, 1e-10));
    });

    test('given: pipeline.normalize(low: 0, high: 1) with mixed positive and negative dy, should: keep y unchanged and scale dy (split from negSum/total)', () {

      final pipeline = DataPointPipeline().normalize(low: 0.0, high: 1.0);
      final input = points([(0.0, 0.0, 3.0), (1.0, 0.0, -2.0)]);
      final out = pipeline.build(input);

      expect(out[0].y, equals(0.0));
      expect(out[1].y, equals(0.0));
      expect(out[0].dy, closeTo(0.6, 1e-10));
      expect(out[1].dy, closeTo(0.4, 1e-10));
    });

    test('given: pipeline.normalize() and all zero dy, should: return input unchanged', () {

      final pipeline = DataPointPipeline().normalize(low: 0.0, high: 1.0);
      final input = points([(0.0, 7.0, 0.0), (1.0, 8.0, 0.0)]);
      final out = pipeline.build(input);

      expect(out[0].x, equals(0.0));
      expect(out[0].y, equals(7.0));
      expect(out[0].dy, equals(0.0));
      expect(out[1].x, equals(1.0));
      expect(out[1].y, equals(8.0));
      expect(out[1].dy, equals(0.0));
    });

    test('given: pipeline.normalize2pi(), should: use range [0, 2*pi]', () {

      final pipeline = DataPointPipeline().normalize2pi();
      final input = points([(0.0, 0.0, 1.0), (1.0, 0.0, 1.0)]);
      final out = pipeline.build(input);

      final actualSumDy = out[0].dy + out[1].dy;
      final expectedSumDy = 2.0 * pi;

      expect(actualSumDy, closeTo(expectedSumDy, 1e-10));
    });

    test('given: pipeline.normalize(threshold: 2.0) and two equal points, should: remove all and return empty', () {

      final pipeline = DataPointPipeline().normalize(low: 0.0, high: 1.0, threshold: 2.0);
      final input = points([(0.0, 0.0, 1.0), (1.0, 0.0, 1.0)]);
      final out = pipeline.build(input);

      final actual = out.length;
      final expected = 0;

      expect(actual, equals(expected));
    });

    test('given: pipeline.normalize(low: 0, mid: 0, high: 1.0) with mixed dy, should: return all points with negative dy set to 0 and positive scaled to [0,1]', () {

      final pipeline = DataPointPipeline().normalize(low: 0.0, mid: 0.0, high: 1.0);
      final input = points([(0.0, 0.0, -2.0), (1.0, 0.0, 3.0), (2.0, 0.0, -1.0), (3.0, 0.0, 5.0)]);
      final out = pipeline.build(input);

      final actualLength = out.length;
      final expectedLength = 4;
      final actualSumDy = out[0].dy + out[1].dy + out[2].dy + out[3].dy;
      final expectedSumDy = 1.0;

      expect(actualLength, equals(expectedLength));
      expect(out[0].dy, equals(0.0));
      expect(out[1].dy, closeTo(3.0 / 8.0, 1e-10));
      expect(out[2].dy, equals(0.0));
      expect(out[3].dy, closeTo(5.0 / 8.0, 1e-10));
      expect(actualSumDy, closeTo(expectedSumDy, 1e-10));
    });

    test('given: pipeline.normalize(low: -1, mid: 0, high: 0) with mixed dy, should: return all points with positive dy set to 0 and negative scaled (y unchanged)', () {

      final pipeline = DataPointPipeline().normalize(low: -1.0, mid: 0.0, high: 0.0);
      final input = points([(0.0, 0.0, 4.0), (1.0, 0.0, -3.0), (2.0, 0.0, 2.0), (3.0, 0.0, -5.0)]);
      final out = pipeline.build(input);

      final actualLength = out.length;
      final expectedLength = 4;
      final actualSumDy = out[0].dy + out[1].dy + out[2].dy + out[3].dy;
      final expectedSumDy = 1.0;

      expect(actualLength, equals(expectedLength));
      expect(out[0].y, equals(0.0));
      expect(out[1].y, equals(0.0));
      expect(out[0].dy, equals(0.0));
      expect(out[1].dy, closeTo(3.0 / 8.0, 1e-10));
      expect(out[2].dy, equals(0.0));
      expect(out[3].dy, closeTo(5.0 / 8.0, 1e-10));
      expect(actualSumDy, closeTo(expectedSumDy, 1e-10));
    });

    test('given: pipeline.normalize(low: 0, mid: 0.6, high: 1.0) with 5 points (2 negative, 3 positive), should: keep y unchanged and scale dy into [0,0.6] and [0.6,1]', () {

      final pipeline = DataPointPipeline().normalize(low: 0.0, mid: 0.6, high: 1.0);
      final input = points([(0.0, 0.0, -2.0), (1.0, 0.0, -1.0), (2.0, 0.0, 2.0), (3.0, 0.0, 3.0), (4.0, 0.0, 4.0)]);
      final out = pipeline.build(input);

      final actualLength = out.length;
      final expectedLength = 5;
      final negRange = 0.6;
      final posRange = 0.4;
      final negSum = 3.0;
      final posSum = 9.0;

      expect(actualLength, equals(expectedLength));
      expect(out[0].y, equals(0.0));
      expect(out[1].y, equals(0.0));
      expect(out[2].y, equals(0.0));
      expect(out[3].y, equals(0.0));
      expect(out[4].y, equals(0.0));
      expect(out[0].dy, closeTo(2.0 * negRange / negSum, 1e-10));
      expect(out[1].dy, closeTo(1.0 * negRange / negSum, 1e-10));
      expect(out[2].dy, closeTo(2.0 * posRange / posSum, 1e-10));
      expect(out[3].dy, closeTo(3.0 * posRange / posSum, 1e-10));
      expect(out[4].dy, closeTo(4.0 * posRange / posSum, 1e-10));
    });
  });

  group('Combination', () {

    test('given: pipeline.stack(true).normalize() and two bars at same x, should: stack first then normalize dy only (y unchanged)', () {

      final pipeline = DataPointPipeline().stack(true).normalize(low: 0.0, high: 1.0);
      final input = points([(1.0, 0.0, 6.0), (1.0, 0.0, 4.0)]);
      final out = pipeline.build(input);

      final actualSumDy = out[0].dy + out[1].dy;
      final expectedSumDy = 1.0;
      final actualFirstDy = out[0].dy;
      final actualSecondDy = out[1].dy;

      expect(out[0].y, equals(0.0));
      expect(out[1].y, equals(6.0));
      expect(actualFirstDy, closeTo(0.6, 1e-10));
      expect(actualSecondDy, closeTo(0.4, 1e-10));
      expect(actualSumDy, closeTo(expectedSumDy, 1e-10));
    });

    test('given: pipeline.normalize().stack(true) and two bars at same x, should: normalize first then stack', () {

      final pipeline = DataPointPipeline().normalize(low: 0.0, high: 1.0).stack(true);
      final input = points([(1.0, 0.0, 6.0), (1.0, 0.0, 4.0)]);
      final out = pipeline.build(input);

      final actualFirstY = out[0].y;
      final expectedFirstY = 0.0;
      final actualSecondY = out[1].y;
      final expectedSecondY = 0.6;

      expect(actualFirstY, equals(expectedFirstY));
      expect(actualSecondY, closeTo(expectedSecondY, 1e-10));
    });

    test('given: pipeline.stack(true).normalize() with two x positions, should: stack per x then normalize total', () {

      final pipeline = DataPointPipeline().stack(true).normalize(low: 0.0, high: 1.0);
      final input = points([(0.0, 0.0, 3.0), (0.0, 0.0, 2.0), (1.0, 0.0, 5.0)]);
      final out = pipeline.build(input);

      final actualLen = out.length;
      final expectedLen = 3;
      final actualSumDy = out[0].dy + out[1].dy + out[2].dy;
      final expectedSumDy = 1.0;

      expect(actualLen, equals(expectedLen));
      expect(actualSumDy, closeTo(expectedSumDy, 1e-10));
    });

    test('given: pipeline with spacing 0.1, normalize(low: 0, high: 1.0).stack(true) and four points at same x, should: stack with spacing then normalize', () {

      final pipeline = DataPointPipeline(spacing: 0.1).normalize(low: 0.0, high: 1.0).stack(true);
      final input = points([(1.0, 0.0, 2.0), (1.0, 0.0, 3.0), (1.0, 0.0, 1.0), (1.0, 0.0, 4.0)]);
      final out = pipeline.build(input);

      final actualLength = out.length;
      final expectedLength = 4;
      final totalWithSpacing = 2.0 + 0.1 + 3.0 + 0.1 + 1.0 + 0.1 + 4.0;
      final actualSumDy = out[0].dy + out[1].dy + out[2].dy + out[3].dy;
      final expectedSumDy = 10.0 / totalWithSpacing;

      expect(actualLength, equals(expectedLength));
      expect(out[0].y, equals(0.0));
      expect(out[1].y, closeTo(2.0 / totalWithSpacing + 0.1, 1e-10));
      expect(out[2].y, closeTo((2.0 + 3.0) / totalWithSpacing + 0.2, 1e-10));
      expect(out[3].y, closeTo((2.0 + 3.0 + 1.0) / totalWithSpacing + 0.3, 1e-10));
      expect(actualSumDy, closeTo(expectedSumDy, 1e-10));
    });
  });
}
