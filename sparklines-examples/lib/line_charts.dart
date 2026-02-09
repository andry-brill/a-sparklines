
part of 'main.dart';


final blueLine = [
  dpI(-6, 8),
  dpI(-3, -3),
  dpI(0, 0),
  dpI(3, 7),
  dpI(6, 2),
  dpI(9, 9),
  dpI(12, 3),
  dpI(15, 3),
];

final blueLineMod = [
  dpI(-6, 4),
  dpI(-3, 1),
  dpI(0, -2),
  dpI(3, 6),
  dpI(6, 10),
  dpI(9, 1),
  dpI(12, 5),
  dpI(15, 0),
];

final orangeLine = [
  dpI(-6, 8),
  dpI(-4, -3),
  dpI(-2, 5),
  dpI(0, 9),
  dpI(2, 6),
  dpI(4, 0),
  dpI(8, -2),
  dpI(10, 4),
  dpI(12, -1),
  dpI(14, -5),
  dpI(16, 10),
];

final orangeLineMod = [
  dpI(-6, 4),
  dpI(-4, 0),
  dpI(-2, -1),
  dpI(0, 6),
  dpI(2, 2),
  dpI(4, 0),
  dpI(8, 9),
  dpI(10, -3),
  dpI(12, 5),
  dpI(14, -4),
  dpI(16, 0),
];

const thickness1 = ThicknessData(size: 4, color: Colors.blue);
const thickness2 = ThicknessData(size: 4, color: Colors.deepOrange);

final initialCharts = [
  LineData(
    points: blueLine,
    thickness: thickness1,
  ),
  LineData(
    points: orangeLine,
    thickness: thickness2,
  ),
];

final toggleCharts = [
  LineData(
    points: blueLineMod,
    thickness: thickness1,
  ),
  LineData(
    points: orangeLineMod,
    thickness: thickness2,
  ),
];

final lineBase = ExampleChart(
  title: 'BASE',
  initialCharts: initialCharts,
  toggleCharts: toggleCharts,
);

final lineFull = lineBase.modify(
  title: 'FULL',
  modifier: (c) => c.copyWith(layout: const RelativeLayout.full()),
);

final lineStacker1 = DataPointStacker();
final lineStacker2 = DataPointStacker();

List<ExampleChart> lineCharts() {
  return [
    lineBase.modify(
      title: 'Absolute layout',
      subtitle: 'Raw coordinates with no scaling; chart uses data values directly.',
      modifier: (c) => c,
    ),
    lineBase.modify(
      title: 'Relative finite layout',
      subtitle: 'Chart drawn within explicit bounds (minX–maxX, minY–maxY).',
      modifier: (c) => c.copyWith(layout: RelativeLayout(
        minX: xI(-3),
        minY: yI(-3),
        maxX: xI(12),
        maxY: yI(12),
      )),
    ),
    lineBase.modify(
      title: 'Relative full (independent)',
      subtitle: 'Each line has its own scale; lines are not aligned on the same axes.',
      modifier: (c) => c.copyWith(
          layout: RelativeLayout.full(),
          areaColor: c.thickness.color.withValues(alpha: 0.5)
      ),
    ),
    lineBase.modify(
      title: 'Relative full (shared)',
      subtitle: 'All lines share one scale so values can be compared directly.',
      modifier: (c) => c.copyWith(
          layout: const RelativeLayout.full(),
          areaColor: c.thickness.color.withValues(alpha: 0.5)
      ),
    ),
    lineFull.modify(
      title: 'Rounded caps and joins',
      subtitle: 'Line ends and corners are rounded for a smoother look.',
      modifier: (c) => c.copyWith(isStrokeCapRound: true, isStrokeJoinRound: true),
    ),
    lineFull.modify(
      title: 'Curved lines',
      subtitle: 'Smooth curves between points (smoothness 0.4).',
      modifier: (c) => c.copyWith(lineType: CurvedLineType(smoothness: 0.4)),
    ),
    lineFull.modify(
      title: 'Gradient area fill',
      subtitle: 'Fill under the line with a vertical gradient from line color to transparent.',
      modifier: (c) => c.copyWith(areaGradient: LinearGradient(
        colors: [c.thickness.color, Colors.white],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter
      )),
    ),
    lineFull.modify(
      title: 'Stepped (mid-point)',
      subtitle: 'Horizontal then vertical segments; step occurs midway between each pair of points.',
      modifier: (c) => c.copyWith(
          lineType: SteppedLineType.middle(),
          pointStyle: CircleDataPointStyle(radius: 2, color: Color(0xFF272727))
      ),
    ),
    lineFull.modify(
      title: 'Stepped (end) with transform',
      subtitle: 'Step at end of segment; custom origin, 90° rotation, and rounded joins.',
      modifier: (c) => c.copyWith(
          origin: Offset(-20, 10),
          rotation: pi/2,
          lineType: SteppedLineType.end(),
          isStrokeCapRound: true,
          isStrokeJoinRound: true,
          pointStyle: CircleDataPointStyle(radius: 2, color: Color(0xFF272727)),
          areaGradient: LinearGradient(
              colors: [c.thickness.color.withValues(alpha: 0.5), Colors.white.withValues(alpha: 0.0)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter
          )
      ),
    ),
    ExampleChart<LineData>(
      title: 'Stacked lines',
      subtitle: 'Multiple series stacked vertically using DataPointStacker.',
      modifier: (c) => c.copyWith(
          layout: const RelativeLayout.full(),
          areaColor: c.thickness.color.withValues(alpha: 0.5)
      ),
      initialCharts: [
        LineData(
          points: lineStacker1.stack(blueLine),
          thickness: thickness1,
        ),
        LineData(
          points: lineStacker1.stack(blueLine),
          thickness: thickness2,
        ),
      ].reversed.toList(),
      toggleCharts: [
        LineData(
          points: lineStacker2.stack(blueLineMod),
          thickness: thickness1,
        ),
        LineData(
          points: lineStacker2.stack(blueLineMod),
          thickness: thickness2,
        ),
      ].reversed.toList(),
    )
  ];
}
