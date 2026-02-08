
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

final color1 = Colors.blue;
final color2 = Colors.deepOrange;

final initialCharts = [
  LineData(
    points: blueLine,
    color: color1,
    width: 4
  ),
  LineData(
    points: orangeLine,
    color: color2,
    width: 4
  ),
];

final toggleCharts = [
  LineData(
    points: blueLineMod,
    color: color1,
    width: 4,
  ),
  LineData(
    points: orangeLineMod,
    color: color2,
    width: 4,
  ),
];

final lineBase = ExampleChart(
  title: 'BASE',
  initialCharts: initialCharts,
  toggleCharts: toggleCharts,
);

final lineFull = lineBase.modify(
  title: 'FULL',
  modifier: (c) => c.copyWith(layout: RelativeLayout.full()),
);

List<ExampleChart> lineCharts() {
  return [
    lineBase.modify(
      title: 'Absolute layout',
      subtitle: 'Values rendered as is, no transformation',
      modifier: (c) => c,
    ),
    lineBase.modify(
      title: 'Relative finite layout',
      subtitle: 'Values rendered in specified bounds (mixX-maxX,minY-maxY)',
      modifier: (c) => c.copyWith(layout: RelativeLayout(
        minX: xI(-3),
        minY: yI(-3),
        maxX: xI(12),
        maxY: yI(12),
      )),
    ),
    lineBase.modify(
      title: 'Relative full layout',
      subtitle: 'All values are fit - rendered in bounds between min data and max data',
      modifier: (c) => c.copyWith(layout: RelativeLayout.full()),
    ),
    lineFull.modify(
      title: 'Joins rounded',
      subtitle: 'Stroke cap & join rounded (= true)',
      modifier: (c) => c.copyWith(isStrokeCapRound: true, isStrokeJoinRound: true),
    ),
    lineFull.modify(
      title: 'Curved',
      subtitle: 'Lines rendered as curves, with smoothness=0.4',
      modifier: (c) => c.copyWith(lineType: CurvedLineType(smoothness: 0.4)),
    ),
    lineFull.modify(
      title: 'Gradient area',
      modifier: (c) => c.copyWith(gradientArea: LinearGradient(
        colors: [c.color!, Colors.white],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter
      )),
    ),
    lineFull.modify(
      title: 'Stepped',
      subtitle: 'Lines rendered as steps, with jump in the middle between data points',
      modifier: (c) => c.copyWith(
          lineType: SteppedLineType.middle(),
          pointStyle: CircleDataPointStyle(radius: 2, color: Color(0xFF272727))
      ),
    ),
    lineFull.modify(
      title: 'Stepped and rounded',
      subtitle: 'Jump at end, offset(-20, 10) and rotated 90deg',
      modifier: (c) => c.copyWith(
          origin: Offset(-20, 10),
          rotation: pi/2,
          lineType: SteppedLineType.end(),
          isStrokeCapRound: true,
          isStrokeJoinRound: true,
          pointStyle: CircleDataPointStyle(radius: 2, color: Color(0xFF272727)),
          gradientArea: LinearGradient(
              colors: [c.color!.withValues(alpha: 0.5), Colors.white.withValues(alpha: 0.0)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter
          )
      ),
    ),

  ];
}
