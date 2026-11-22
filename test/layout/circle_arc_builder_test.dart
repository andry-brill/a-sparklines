
import 'dart:math';
import 'dart:ui';

import 'package:any_sparklines/layout/circle_arc_builder.dart';
import 'package:test/test.dart';

void main() {

  group('CircleArcBuilder', () {

    test('given: 2 * pi length with outerRadius, should: have bounds (-outerRadius, outerRadius)', () {

      final donut = CircleArcBuilder(
        innerRadius: 36,
        outerRadius: 72,
        startAngle: 0.0,
        endAngle: 2 * pi
      );

      expect(donut.build().getBounds(), Rect.fromLTRB(-72.0, -72.0, 72.0, 72.0));

      final circle = CircleArcBuilder(
          innerRadius: 0.0,
          outerRadius: 72.0,
          startAngle: 0.0,
          endAngle: 2 * pi
      );

      expect(circle.build().getBounds(), Rect.fromLTRB(-72.0, -72.0, 72.0, 72.0));

    });

  });

}