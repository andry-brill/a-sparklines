import 'package:any_sparklines/any_sparklines.dart';
import 'package:flutter/material.dart' show Colors;
import 'package:test/test.dart';

void main() {
  const points = [DataPoint(x: 1.0, y: 2.0, dy: 0.0)];

  group('LineData scatter mode', () {
    test('given: built-in connected line types, should: require two points',
        () {
      const lineTypes = <ILineTypeData>[
        LinearLineData(),
        SteppedLineData(),
        CurvedLineData(),
      ];

      for (final lineType in lineTypes) {
        expect(lineType.drawLine, isTrue);
        expect(lineType.minPoints, equals(2));
      }
    });

    test(
        'given: regular and scatter constructors, should: select their line type',
        () {
      const line = LineData(line: points);
      const scatter = LineData.scatter(points: points);

      expect(line.lineType, isA<LinearLineData>());
      expect(line.lineType.drawLine, isTrue);
      expect(line.lineType.minPoints, equals(2));
      expect(scatter.lineType, isA<ScatterLineData>());
      expect(scatter.lineType.drawLine, isFalse);
      expect(scatter.lineType.minPoints, equals(1));
      expect(
        () => scatter.lineType.renderer,
        throwsA(isA<UnsupportedError>()),
      );
      expect(scatter.line, same(points));
    });

    test(
        'given: scatter data, should: preserve its type and dormant line styles through copyWith',
        () {
      const scatter = LineData.scatter(points: points);
      final copied = scatter.copyWith(
        thickness: const ThicknessData(size: Px(4.0), color: Colors.red),
        areaColor: Colors.blue,
      );

      expect(copied.lineType, isA<ScatterLineData>());
      expect(copied.lineType.drawLine, isFalse);
      expect(copied.thickness,
          equals(const ThicknessData(size: Px(4.0), color: Colors.red)));
      expect(copied.areaColor, equals(Colors.blue));
    });

    test(
        'given: scatter data copied with a connected line type, should: become a line',
        () {
      const scatter = LineData.scatter(points: points);
      final copied = scatter.copyWith(lineType: const CurvedLineData());

      expect(copied.lineType, isA<CurvedLineData>());
      expect(copied.lineType.drawLine, isTrue);
      expect(copied.lineType.minPoints, equals(2));
    });

    test(
        'given: matching line and scatter data, should: repaint when mode changes',
        () {
      const line = LineData(line: points);
      const scatter = LineData.scatter(points: points);

      expect(line.shouldRepaint(scatter), isTrue);
      expect(scatter.shouldRepaint(line), isTrue);
    });

    test(
        'given: interpolation between line and scatter data, should: adopt destination type',
        () {
      const line = LineData(line: points);
      const scatter = LineData.scatter(points: points);

      final toScatter = line.lerpTo(scatter, 0.5) as LineData;
      final toLine = scatter.lerpTo(line, 0.5) as LineData;

      expect(toScatter.lineType, isA<ScatterLineData>());
      expect(toLine.lineType, isA<LinearLineData>());
    });
  });
}
