import 'dart:math';

import 'package:any_sparklines/interfaces/data_point_data.dart';
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

    test('given: pipeline.stack() and one point, should: leave y at 0 and dy unchanged', () {

      final pipeline = DataPointPipeline().stack();
      final input = pointList(2.0, 0.0, 7.0);
      final out = pipeline.build(input);

      final actualY = out[0].y;
      final expectedY = 0.0;
      final actualDy = out[0].dy;
      final expectedDy = 7.0;

      expect(actualY, equals(expectedY));
      expect(actualDy, equals(expectedDy));
    });

    test('given: pipeline.stack() and two bars at same x, should: second bar starts at top of first', () {

      final pipeline = DataPointPipeline().stack();
      final input = points([(1.0, 0.0, 6.0), (1.0, 0.0, 4.0)]);
      final out = pipeline.build(input);

      final actualFirstY = out[0].y;
      final expectedFirstY = 0.0;
      final actualSecondY = out[1].y;
      final expectedSecondY = 6.0;

      expect(actualFirstY, equals(expectedFirstY));
      expect(actualSecondY, equals(expectedSecondY));
    });

    test('given: pipeline.stack(spacing: 1.0) and two bars at same x, should: add spacing between stacked values', () {

      final pipeline = DataPointPipeline().stack(spacing: 1.0);
      final input = points([(1.0, 0.0, 6.0), (1.0, 0.0, 4.0)]);
      final out = pipeline.build(input);

      final actualSecondY = out[1].y;
      final expectedSecondY = 7.0;

      expect(actualSecondY, equals(expectedSecondY));
    });

    test('given: pipeline.stack() and bars at different x, should: stack independently per x', () {

      final pipeline = DataPointPipeline().stack();
      final input = points([(0.0, 0.0, 5.0), (1.0, 0.0, 10.0), (0.0, 0.0, 3.0)]);
      final out = pipeline.build(input);

      final actualThirdY = out[2].y;
      final expectedThirdY = 5.0;

      expect(actualThirdY, equals(expectedThirdY));
    });

  });

  group('NormalizeModifier', () {

    test('given: pipeline.normalize() and empty input, should: return empty list', () {

      final pipeline = DataPointPipeline().normalize(total: 1.0);
      final input = <DataPoint>[];
      final out = pipeline.build(input);

      final actual = out.length;
      final expected = 0;

      expect(actual, equals(expected));
    });

    test('given: pipeline.normalize() and single point with positive dy, should: scale dy to total', () {

      final pipeline = DataPointPipeline().normalize(total: 1.0);
      final input = pointList(0.0, 0.0, 100.0);
      final out = pipeline.build(input);

      final actualDy = out[0].dy;
      final expectedDy = 1.0;

      expect(actualDy, equals(expectedDy));
    });

    test('given: pipeline.normalize(total: 1.0) and positive dy only, should: scale sum to total', () {

      final pipeline = DataPointPipeline().normalize(total: 1.0);
      final input = points([(0.0, 0.0, 4.0), (1.0, 0.0, 6.0)]);
      final out = pipeline.build(input);

      final actualFirstDy = out[0].dy;
      final actualSecondDy = out[1].dy;
      final expectedFirstDy = 0.4;
      final expectedSecondDy = 0.6;

      expect(actualFirstDy, closeTo(expectedFirstDy, 1e-10));
      expect(actualSecondDy, closeTo(expectedSecondDy, 1e-10));
    });

    test('given: pipeline.normalize(total: 1.0) with mixed positive and negative dy, should: scale abs(dy) to total', () {

      final pipeline = DataPointPipeline().normalize(total: 1.0);
      final input = points([(0.0, 0.0, 3.0), (1.0, 0.0, -2.0)]);
      final out = pipeline.build(input);

      expect(out[0].y, equals(0.0));
      expect(out[1].y, equals(0.0));
      expect(out[0].dy, closeTo(0.6, 1e-10));
      expect(out[1].dy, closeTo(0.4, 1e-10));
    });

    test('given: pipeline.normalize() and all zero dy, should: return input unchanged', () {

      final pipeline = DataPointPipeline().normalize(total: 1.0);
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

    test('given: pipeline.normalize2pi(spacingDeg: 15), should: use range [0, 2*pi] with two spaces', () {

      final pipeline = DataPointPipeline().normalize2pi(spacingDeg: 15); // Expecting trailingSpacing: true
      final input = points([(1.0, 0.0, 1.0), (1.0, 0.0, 1.0)]);
      final out = pipeline.build(input);

      final actualSumDy = out[0].dy + out[1].dy;
      final expectedSumDy = 2.0 * pi - (15 * 2) * (pi / 180.0);

      expect(actualSumDy, closeTo(expectedSumDy, 1e-10));
    });

    test('given: pipeline.normalize2pi(total: 1, spacingDeg: 15), should: use range [0, 1*pi] with one space', () {

      final pipeline = DataPointPipeline().normalize2pi(total: 1, spacingDeg: 15); // Expecting trailingSpacing: false
      final input = points([(1.0, 0.0, 1.0), (1.0, 0.0, 1.0)]);
      final out = pipeline.build(input);

      final actualSumDy = out[0].dy + out[1].dy;
      final expectedSumDy = pi - (15 * 1) * (pi / 180.0);

      expect(actualSumDy, closeTo(expectedSumDy, 1e-10));
    });

    test('given: pipeline.normalize(threshold: 2.0) and two equal points, should: remove all and return empty', () {

      final pipeline = DataPointPipeline().normalize(total: 1.0, threshold: 2.0);
      final input = points([(0.0, 0.0, 1.0), (1.0, 0.0, 1.0)]);
      final out = pipeline.build(input);

      final actual = out.length;
      final expected = 0;

      expect(actual, equals(expected));
    });

    test('given: pipeline.normalize(threshold: 2.0, thresholdPoint: DataPoint(x: 0, dy: 0)) and two equal points, should: return single point with normalized accumulated dy', () {

      final pipeline = DataPointPipeline().normalize(
        total: 1.0,
        threshold: 2.0,
        thresholdPoint: const DataPoint(x: 0.0, y: 0.0, dy: 0.0),
      );
      final input = points([(0.0, 0.0, 1.0), (1.0, 0.0, 1.0)]);
      final out = pipeline.build(input);

      final actualLength = out.length;
      final expectedLength = 1;
      final actualDy = out[0].dy;
      final expectedDy = 1.0;

      expect(actualLength, equals(expectedLength));
      expect(out[0].x, equals(0.0));
      expect(out[0].y, equals(0.0));
      expect(actualDy, equals(expectedDy));
    });

    test('given: pipeline.normalize(threshold: 0.4, thresholdPoint: DataPoint(x: 0, dy: 0)) and three points (one small), should: remove small point and include thresholdPoint in result with accumulated dy', () {

      final pipeline = DataPointPipeline().normalize(
        total: 1.0,
        threshold: 0.4,
        thresholdPoint: const DataPoint(x: 0.0, y: 0.0, dy: 0.0),
      );
      final input = points([(0.0, 0.0, 0.1), (1.0, 0.0, 0.5), (2.0, 0.0, 0.4)]);
      final out = pipeline.build(input);

      expect(out.length, greaterThanOrEqualTo(2));
      final thresholdPoint = out.firstWhere((p) => p.x == 0.0 && p.dy != 0.0, orElse: () => out.first);
      expect(thresholdPoint.dy, greaterThan(0.0));
    });

    test('given: pipeline.normalize(threshold: 0.3, thresholdPoint: DataPoint(x: -1, dy: 0)) and points all below threshold, should: include thresholdPoint with accumulated dy (may absorb result points until threshold met)', () {

      final pipeline = DataPointPipeline().normalize(
        total: 1.0,
        threshold: 0.3,
        thresholdPoint: const DataPoint(x: -1.0, y: 0.0, dy: 0.0),
      );
      final input = points([(0.0, 0.0, 0.1), (1.0, 0.0, 0.1), (2.0, 0.0, 0.05)]);
      final out = pipeline.build(input);

      final thresholdPt = out.where((p) => p.x == -1.0).toList();

      expect(thresholdPt.length, equals(1));
      expect(thresholdPt[0].dy, greaterThan(0.0));
    });

    test('given: pipeline.normalize(threshold: 0.0, thresholdPoint: DataPoint(x: 0, dy: 0)) and positive points, should: not add thresholdPoint when dy remains zero', () {

      final pipeline = DataPointPipeline().normalize(
        total: 1.0,
        threshold: 0.0,
        thresholdPoint: const DataPoint(x: 0.0, y: 0.0, dy: 0.0),
      );
      final input = points([(0.0, 0.0, 1.0), (1.0, 0.0, 1.0)]);
      final out = pipeline.build(input);

      final actualLength = out.length;
      final expectedLength = 2;

      expect(actualLength, equals(expectedLength));
      expect(out.any((p) => p.x == 0.0 && p.dy == 0.0), isFalse);
    });
  });

  group('RescaleModifier', () {

    test('given: intervals [0,0], [0,1], [0,2] pipeline.rescale(), should: rescale to [0,1] with dy (0.0, 0.5, 1.0)', () {

      final pipeline = DataPointPipeline().rescale();
      final input = points([(0.0, 0.0, 0.0), (1.0, 0.0, 1.0), (2.0, 0.0, 2.0)]);
      final out = pipeline.build(input);

      expect(out.length, equals(3));
      expect(out[0].y, equals(0.0));
      expect(out[0].fy, equals(0.0));
      expect(out[0].dy, equals(0.0));
      expect(out[1].y, equals(0.0));
      expect(out[1].fy, equals(0.5));
      expect(out[1].dy, equals(0.5));
      expect(out[2].y, equals(0.0));
      expect(out[2].fy, equals(1.0));
      expect(out[2].dy, equals(1.0));
    });

    test('given: intervals [-4,-4], [-4,-2], [-2,2] pipeline.rescale(currentMin: -4.0, currentMax: 4.0, targetMin: -1.0), should: rescale to [-1,1] with dy (0, 0.5, 1.0)', () {

      final pipeline = DataPointPipeline().rescale(currentMin: -4.0, currentMax: 4.0, targetMin: -1.0);
      final input = points([(0.0, -4.0, 0.0), (1.0, -4.0, 2.0), (2.0, -2.0, 4.0)]);
      final out = pipeline.build(input);

      expect(out.length, equals(3));
      expect(out[0].y, equals(-1.0));
      expect(out[0].fy, equals(-1.0));
      expect(out[0].dy, equals(0.0));
      expect(out[1].y, equals(-1.0));
      expect(out[1].fy, equals(-0.5));
      expect(out[1].dy, equals(0.5));
      expect(out[2].y, equals(-0.5));
      expect(out[2].fy, equals(0.5));
      expect(out[2].dy, equals(1.0));
    });

    test('given: intervals [0,-2], [0,1], [0,4] pipeline.rescale(), should: rescale both y and fy to [0,1] (bounds -2..4)', () {

      final pipeline = DataPointPipeline().rescale();
      final input = points([(0.0, 0.0, -2.0), (1.0, 0.0, 1.0), (2.0, 0.0, 4.0)]);
      final out = pipeline.build(input);

      expect(out.length, equals(3));
      // Bounds -2..4, span 6 → [0,1]: (v+2)/6
      expect(out[0].y, closeTo(1 / 3.0, 1e-10));
      expect(out[0].fy, equals(0.0));
      expect(out[0].dy, closeTo(-1 / 3.0, 1e-10));
      expect(out[1].y, closeTo(1 / 3.0, 1e-10));
      expect(out[1].fy, closeTo(0.5, 1e-10));
      expect(out[1].dy, closeTo(1 / 6.0, 1e-10));
      expect(out[2].y, closeTo(1 / 3.0, 1e-10));
      expect(out[2].fy, equals(1.0));
      expect(out[2].dy, closeTo(2 / 3.0, 1e-10));
    });

    test('given: points [0,-2], [0,1] and points [0,1], [0,4] pipeline.rescale(), should: rescale both y and fy to [0,1] (bounds -2..4)', () {

      final pipeline = DataPointPipeline().rescale();
      final input1 = points([(0.0, 0.0, -2.0), (1.0, 0.0, 1.0)]);
      final input2 = points([(1.0, 0.0, 1.0), (2.0, 0.0, 4.0)]);

      final out1 = pipeline.build(input1);
      final out2 = pipeline.build(input2);

      expect(out1.length, equals(2));
      expect(out2.length, equals(2));

      // Bounds -2..4, span 6 → [0,1]: (v+2)/6
      expect(out1[0].y, closeTo(1 / 3.0, 1e-10));
      expect(out1[0].fy, equals(0.0));
      expect(out1[0].dy, closeTo(-1 / 3.0, 1e-10));

      expect(out1[1].y, closeTo(1 / 3.0, 1e-10));
      expect(out1[1].fy, closeTo(0.5, 1e-10));
      expect(out1[1].dy, closeTo(1 / 6.0, 1e-10));

      expect(out2[0].y, closeTo(1 / 3.0, 1e-10));
      expect(out2[0].fy, closeTo(0.5, 1e-10));
      expect(out2[0].dy, closeTo(1 / 6.0, 1e-10));

      expect(out2[1].y, closeTo(1 / 3.0, 1e-10));
      expect(out2[1].fy, equals(1.0));
      expect(out2[1].dy, closeTo(2 / 3.0, 1e-10));
    });
  });

  group('Combination', () {

    test('given: pipeline.stack().normalize() and two bars at same x, should: stack first then normalize dy only (y unchanged)', () {

      final pipeline = DataPointPipeline().stack().normalize(total: 1.0);
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

    test('given: pipeline.normalize().stack() and two bars at same x, should: normalize first then stack', () {

      final pipeline = DataPointPipeline().normalize(total: 1.0).stack();
      final input = points([(1.0, 0.0, 6.0), (1.0, 0.0, 4.0)]);
      final out = pipeline.build(input);

      final actualFirstY = out[0].y;
      final expectedFirstY = 0.0;
      final actualSecondY = out[1].y;
      final expectedSecondY = 0.6;

      expect(actualFirstY, equals(expectedFirstY));
      expect(actualSecondY, closeTo(expectedSecondY, 1e-10));
    });

    test('given: pipeline.stack().normalize() with two x positions, should: stack per x then normalize total', () {

      final pipeline = DataPointPipeline().stack().normalize(total: 1.0);
      final input = points([(0.0, 0.0, 3.0), (0.0, 0.0, 2.0), (1.0, 0.0, 5.0)]);
      final out = pipeline.build(input);

      final actualLen = out.length;
      final expectedLen = 3;
      final actualSumDy = out[0].dy + out[1].dy + out[2].dy;
      final expectedSumDy = 1.0;

      expect(actualLen, equals(expectedLen));
      expect(actualSumDy, closeTo(expectedSumDy, 1e-10));
    });

    test('given: pipeline.normalize(total: 1.0).stack(spacing: 0.1) and four points at same x, should: normalize then stack with spacing', () {

      final pipeline = DataPointPipeline().normalize(total: 1.0).stack(spacing: 0.1);
      final input = points([(1.0, 0.0, 2.0), (1.0, 0.0, 3.0), (1.0, 0.0, 1.0), (1.0, 0.0, 4.0)]);
      final out = pipeline.build(input);

      final actualLength = out.length;
      final expectedLength = 4;
      final actualSumDy = out[0].dy + out[1].dy + out[2].dy + out[3].dy;
      final expectedSumDy = 1.0;

      expect(actualLength, equals(expectedLength));
      expect(out[0].y, equals(0.0));
      expect(out[1].y, closeTo(0.2 + 0.1, 1e-10));
      expect(out[2].y, closeTo(0.2 + 0.1 + 0.3 + 0.1, 1e-10));
      expect(out[3].y, closeTo(0.2 + 0.1 + 0.3 + 0.1 + 0.1 + 0.1, 1e-10));
      expect(actualSumDy, closeTo(expectedSumDy, 1e-10));
    });


    test('given: pipeline.normalize(total, spacing, threshold, thresholdPoint).stack(spacing) and four points at same x, should: normalize then stack, threshold with spacing', () {

      final spacing = 0.1;
      final pipeline = DataPointPipeline()
          .normalize(total: 1.0 + (spacing * 2), spacing: spacing, threshold: 0.01, thresholdPoint: DataPoint(x: 1.0, dy: 0.0))
          .stack(spacing: spacing);
      final input = points([(1.0, 0.0, 0.95), (1.0, 0.0, 3), (1.0, 0.0, 6.0), (1.0, 0.0, 0.05)]);
      final out = pipeline.build(input);

      final actualLength = out.length;
      final expectedLength = 3;
      expect(actualLength, equals(expectedLength));

      expect(out[0].y, equals(0.0));
      expect(out[0].dy, equals(0.3));
      expect(out[0].fy, equals(0.3));

      expect(out[1].y, equals(0.4));
      expect(out[1].dy, equals(0.6));
      expect(out[1].fy, equals(1.0));

      expect(out[2].y, equals(1.1));
      expect(out[2].dy, equals(0.1));
      expect(out[2].fy, equals(1.2));

      final thresholdPoints = out[2].of<IThresholdPoints>();
      expect(thresholdPoints, isNotNull);

      final tps = thresholdPoints!.thresholdPoints;
      expect(tps[0], equals(input.last));
      expect(tps[1], equals(input.first));
    });

  });

  group('SortModifier', () {

    test('given: sort() with no args, should: sort by x ascending by default', () {
      final pipeline = DataPointPipeline().sort();
      final input = points([(2.0, 1.0, 1.0), (1.0, 2.0, 1.0)]);
      final out = pipeline.build(input);
      expect(out[0].x, equals(1.0));
      expect(out[1].x, equals(2.0));
    });

    test('given: sort(x: true), should: sort by x ascending', () {
      final pipeline = DataPointPipeline().sort(x: true);
      final input = points([(2.0, 0.0, 1.0), (1.0, 0.0, 1.0), (3.0, 0.0, 1.0)]);
      final out = pipeline.build(input);
      expect(out[0].x, equals(1.0));
      expect(out[1].x, equals(2.0));
      expect(out[2].x, equals(3.0));
    });

    test('given: sort(x: false), should: sort by x descending', () {
      final pipeline = DataPointPipeline().sort(x: false);
      final input = points([(1.0, 0.0, 1.0), (3.0, 0.0, 1.0), (2.0, 0.0, 1.0)]);
      final out = pipeline.build(input);
      expect(out[0].x, equals(3.0));
      expect(out[1].x, equals(2.0));
      expect(out[2].x, equals(1.0));
    });

    test('given: sort(y: true), should: sort by y ascending', () {
      final pipeline = DataPointPipeline().sort(y: true);
      final input = points([(0.0, 3.0, 1.0), (0.0, 1.0, 1.0), (0.0, 2.0, 1.0)]);
      final out = pipeline.build(input);
      expect(out[0].y, equals(1.0));
      expect(out[1].y, equals(2.0));
      expect(out[2].y, equals(3.0));
    });

    test('given: sort(fy: false), should: sort by fy descending', () {
      final pipeline = DataPointPipeline().sort(fy: false);
      final input = points([(0.0, 0.0, 1.0), (0.0, 0.0, 3.0), (0.0, 0.0, 2.0)]);
      final out = pipeline.build(input);
      expect(out[0].fy, equals(3.0));
      expect(out[1].fy, equals(2.0));
      expect(out[2].fy, equals(1.0));
    });

    test('given: sort(x: true, y: false), should: sort by x asc then y desc', () {
      final pipeline = DataPointPipeline().sort(x: true, y: false);
      final input = points([
        (1.0, 2.0, 1.0),
        (1.0, 1.0, 1.0),
        (0.0, 0.0, 1.0),
      ]);
      final out = pipeline.build(input);
      expect(out[0].x, equals(0.0));
      expect(out[0].y, equals(0.0));
      expect(out[1].x, equals(1.0));
      expect(out[1].y, equals(2.0));
      expect(out[2].x, equals(1.0));
      expect(out[2].y, equals(1.0));
    });

  });

  group('AggregationModifier', () {
    final aggregationInput = points([
      (0.0, 0.0, 2.0),
      (1.0, 0.0, 4.0),
      (2.0, 0.0, 6.0),
      (3.0, 0.0, 8.0),
      (4.0, 0.0, 10.0),
    ]);

    test('sum, no window: cumulative sum of dy', () {
      final pipeline = DataPointPipeline().aggregate(function: DataAggregation.sum);
      final out = pipeline.build(aggregationInput);
      expect(out.length, equals(5));
      expect(out[0].dy, equals(2.0));
      expect(out[1].dy, equals(6.0));
      expect(out[2].dy, equals(12.0));
      expect(out[3].dy, equals(20.0));
      expect(out[4].dy, equals(30.0));
    });

    test('sum, window 2: sum of last two dy', () {
      final pipeline = DataPointPipeline().aggregate(function: DataAggregation.sum, window: 2);
      final out = pipeline.build(aggregationInput);
      expect(out.length, equals(5));
      expect(out[0].dy, equals(2.0));
      expect(out[1].dy, equals(6.0));
      expect(out[2].dy, equals(10.0));
      expect(out[3].dy, equals(14.0));
      expect(out[4].dy, equals(18.0));
    });

    test('avg, no window: cumulative average of dy', () {
      final pipeline = DataPointPipeline().aggregate(function: DataAggregation.avg);
      final out = pipeline.build(aggregationInput);
      expect(out.length, equals(5));
      expect(out[0].dy, equals(2.0));
      expect(out[1].dy, equals(3.0));
      expect(out[2].dy, equals(4.0));
      expect(out[3].dy, equals(5.0));
      expect(out[4].dy, equals(6.0));
    });

    test('avg, window 2: average of last two dy', () {
      final pipeline = DataPointPipeline().aggregate(function: DataAggregation.avg, window: 2);
      final out = pipeline.build(aggregationInput);
      expect(out.length, equals(5));
      expect(out[0].dy, equals(2.0));
      expect(out[1].dy, equals(3.0));
      expect(out[2].dy, equals(5.0));
      expect(out[3].dy, equals(7.0));
      expect(out[4].dy, equals(9.0));
    });

    test('min, no window: running minimum of dy', () {
      final pipeline = DataPointPipeline().aggregate(function: DataAggregation.min);
      final out = pipeline.build(aggregationInput);
      expect(out.length, equals(5));
      expect(out[0].dy, equals(2.0));
      expect(out[1].dy, equals(2.0));
      expect(out[2].dy, equals(2.0));
      expect(out[3].dy, equals(2.0));
      expect(out[4].dy, equals(2.0));
    });

    test('min, window 2: min of last two dy', () {
      final pipeline = DataPointPipeline().aggregate(function: DataAggregation.min, window: 2);
      final out = pipeline.build(aggregationInput);
      expect(out.length, equals(5));
      expect(out[0].dy, equals(2.0));
      expect(out[1].dy, equals(2.0));
      expect(out[2].dy, equals(4.0));
      expect(out[3].dy, equals(6.0));
      expect(out[4].dy, equals(8.0));
    });

    test('max, no window: running maximum of dy', () {
      final pipeline = DataPointPipeline().aggregate(function: DataAggregation.max);
      final out = pipeline.build(aggregationInput);
      expect(out.length, equals(5));
      expect(out[0].dy, equals(2.0));
      expect(out[1].dy, equals(4.0));
      expect(out[2].dy, equals(6.0));
      expect(out[3].dy, equals(8.0));
      expect(out[4].dy, equals(10.0));
    });

    test('max, window 2: max of last two dy', () {
      final pipeline = DataPointPipeline().aggregate(function: DataAggregation.max, window: 2);
      final out = pipeline.build(aggregationInput);
      expect(out.length, equals(5));
      expect(out[0].dy, equals(2.0));
      expect(out[1].dy, equals(4.0));
      expect(out[2].dy, equals(6.0));
      expect(out[3].dy, equals(8.0));
      expect(out[4].dy, equals(10.0));
    });

    test('median, no window: cumulative median of dy', () {
      final pipeline = DataPointPipeline().aggregate(function: DataAggregation.median);
      final out = pipeline.build(aggregationInput);
      expect(out.length, equals(5));
      expect(out[0].dy, equals(2.0));
      expect(out[1].dy, equals(3.0)); // [2,4] -> 3
      expect(out[2].dy, equals(4.0)); // [2,4,6] -> 4
      expect(out[3].dy, equals(5.0)); // [2,4,6,8] -> 5
      expect(out[4].dy, equals(6.0)); // [2,4,6,8,10] -> 6
    });

    test('median, window 2: median of last two dy', () {
      final pipeline = DataPointPipeline().aggregate(function: DataAggregation.median, window: 2);
      final out = pipeline.build(aggregationInput);
      expect(out.length, equals(5));
      expect(out[0].dy, equals(2.0));
      expect(out[1].dy, equals(3.0));
      expect(out[2].dy, equals(5.0));
      expect(out[3].dy, equals(7.0));
      expect(out[4].dy, equals(9.0));
    });

    test('std, no window: cumulative sample std of dy', () {
      final pipeline = DataPointPipeline().aggregate(function: DataAggregation.std);
      final out = pipeline.build(aggregationInput);
      expect(out.length, equals(5));
      expect(out[0].dy, equals(0.0)); // single value
      expect(out[1].dy, closeTo(sqrt(2.0), 1e-9)); // [2,4] std = sqrt(2)
      expect(out[2].dy, equals(2.0)); // [2,4,6] mean=4, var=4, std=2
      expect(out[3].dy, closeTo(sqrt(20 / 3), 1e-9));
      expect(out[4].dy, closeTo(sqrt(10.0), 1e-9));
    });

    test('std, window 2: sample std of last two dy', () {
      final pipeline = DataPointPipeline().aggregate(function: DataAggregation.std, window: 2);
      final out = pipeline.build(aggregationInput);
      expect(out.length, equals(5));
      expect(out[0].dy, equals(0.0));
      expect(out[1].dy, closeTo(sqrt(2.0), 1e-9));
      expect(out[2].dy, closeTo(sqrt(2.0), 1e-9));
      expect(out[3].dy, closeTo(sqrt(2.0), 1e-9));
      expect(out[4].dy, closeTo(sqrt(2.0), 1e-9));
    });
  });
}
