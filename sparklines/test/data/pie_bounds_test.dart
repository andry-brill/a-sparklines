import 'dart:math';
import 'dart:ui';

import 'package:any_sparklines/any_sparklines.dart';
import 'package:test/test.dart';

void main() {
  test('pie data bounds exclude all visual lengths', () {
    const pies = [DataPoint(x: 10, y: 0, dy: 2 * pi)];
    final pixels = PieData(
      pies: pies,
      thickness: const ThicknessData(size: Px(2)),
      border: const ThicknessData(size: Px(1)),
      borderRadius: const Px(3),
      pointStyle:
          const CircleDataPointStyle(radius: Px(4), color: Color(0xff000000)),
    );
    final responsive = PieData(
      pies: pies,
      thickness: const ThicknessData(size: Vw(80)),
      border: const ThicknessData(size: Vh(50)),
      borderRadius: const Dx(5),
      pointStyle:
          const CircleDataPointStyle(radius: Dy(3), color: Color(0xff000000)),
    );

    expect(pixels.bounds, const Rect.fromLTRB(-10, -10, 10, 10));
    expect(responsive.bounds, pixels.bounds);
  });

  test('pie data bounds retain partial arc and data-space offset geometry', () {
    final pie = PieData(
      pies: const [DataPoint(x: 10, y: 0, dy: pi / 2)],
      pieOffset: 2,
      thickness: const ThicknessData(size: Vw(50)),
    );

    final center = Offset(sqrt(2), sqrt(2));
    expect(pie.bounds.left, closeTo(center.dx, 1e-10));
    expect(pie.bounds.top, closeTo(center.dy, 1e-10));
    expect(pie.bounds.right, closeTo(center.dx + 10, 1e-10));
    expect(pie.bounds.bottom, closeTo(center.dy + 10, 1e-10));
  });
}
