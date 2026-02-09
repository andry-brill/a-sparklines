
part of 'main.dart';

final blueBars = [
  dpI(0, 2),
  dpI(2, 5),
  dpI(4, 3),
  dpI(6, 7),
  dpI(8, 4),
  dpI(10, 6),
  dpI(12, 2),
  dpI(14, 5),
  dpI(16, 3),
];

final blueBarsMod = [
  dpI(0, 4),
  dpI(2, 2),
  dpI(4, 6),
  dpI(6, 3),
  dpI(8, 7),
  dpI(10, 4),
  dpI(12, 5),
  dpI(14, 3),
  dpI(16, 9),
];

final orangeBars = [
  dpI(-6, 3),
  dpI(-3, 2),
  dpI(0, 4),
  dpI(3, 1),
  dpI(6, 5),
  dpI(9, 2),
  dpI(12, 4),
  dpI(15, 3),
];

final orangeBarsMod = [
  dpI(-6, 2),
  dpI(-3, 4),
  dpI(0, 1),
  dpI(3, 5),
  dpI(6, 2),
  dpI(9, 4),
  dpI(12, 3),
  dpI(15, 2),
];

const thicknessBar1 = ThicknessData(size: 6, color: Colors.blue);
const thicknessBar2 = ThicknessData(size: 6, color: Colors.deepOrange);

final barSimpleInitial = [
  BarData(bars: blueBars, thickness: thicknessBar1),
  BarData(bars: orangeBars, thickness: thicknessBar2),
];

final barSimpleToggle = [
  BarData(bars: blueBarsMod, thickness: thicknessBar1),
  BarData(bars: orangeBarsMod, thickness: thicknessBar2),
];


final barStacker1 = DataPointStacker();
final barStacker2 = DataPointStacker();

final barStackedInitial = [
  BarData(bars: barStacker1.stack(blueBars), thickness: thicknessBar1),
  BarData(bars: barStacker1.stack(blueBars), thickness: thicknessBar2),
];

final barStackedToggle = [
  BarData(bars: barStacker2.stack(blueBarsMod), thickness: thicknessBar1),
  BarData(bars: barStacker2.stack(blueBarsMod), thickness: thicknessBar2),
];

final barBase = ExampleChart(
  title: 'Simple bar',
  initialCharts: barSimpleInitial,
  toggleCharts: barSimpleToggle,
);

final barFull = barBase.modify(
  title: 'FULL',
  modifier: (c) => c.copyWith(layout: const RelativeLayout.full()),
);

List<ExampleChart> barCharts() {
  return [
    barBase.modify(
      title: 'Absolute layout',
      subtitle: 'Raw coordinates with no scaling; chart uses data values directly.',
      modifier: (c) => c,
    ),
    barBase.modify(
      title: 'Relative finite layout',
      subtitle: 'Chart drawn within explicit bounds (minX–maxX, minY–maxY).',
      modifier: (c) => c.copyWith(layout: RelativeLayout(
        minX: xI(0),
        minY: yI(0),
        maxX: xI(12),
        maxY: yI(12),
      )),
    ),
    barBase.modify(
      title: 'Relative full (independent)',
      subtitle: 'Each series has its own scale; bars are not aligned on the same axes.',
      modifier: (c) => c.copyWith(layout: RelativeLayout.full()),
    ),
    barBase.modify(
      title: 'Relative full (shared)',
      subtitle: 'All series share one scale so values can be compared directly.',
      modifier: (c) => c.copyWith(layout: const RelativeLayout.full()),
    ),
    ExampleChart<BarData>(
      title: 'Stacked bars',
      subtitle: 'Multiple bar series drawn in the same chart.',
      modifier: (c) => c.copyWith(layout: const RelativeLayout.full()),
      initialCharts: barStackedInitial,
      toggleCharts: barStackedToggle,
    ),
    barFull.modify(
      title: 'Border and borderRadius',
      subtitle: 'Bars with an outline and rounded corners.',
      modifier: (c) => c.copyWith(
        border: const ThicknessData(size: 2, color: Color(0xFFff00FF)),
        borderRadius: 5,
      ),
    ),
    barFull.modify(
      title: 'Data points',
      modifier: (c) => c.copyWith(
          borderRadius: 4,
          pointStyle: CircleDataPointStyle(radius: 3, color: Color(0xFF272727))
      ),
    ),
  ];
}
