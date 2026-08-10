import 'dart:math';

import 'package:flutter/material.dart';
import 'package:any_sparklines/any_sparklines.dart';



final bigPie = PieData(
  pies: [
    DataPoint(x: 100.0, y: 0, dy: pi / 6.0),
    DataPoint(
      x: 100.0,
      y: pi / 6.0,
      dy: pi / 6.0,
      data: {
        IThicknessOverride: ThicknessOverride(
          size: Dx(30),
          align: ThicknessData.alignOutside,
          color: chartSecondaryColor,
        ),
      }
    ),
    DataPoint(
      x: 100.0,
      y: pi / 3.0,
      dy: pi / 6.0,
      data: {
        IThicknessOverride: ThicknessOverride(
          size: Dx(40),
          align: ThicknessData.alignOutside,
          color: chartDarkColor,
        ),
      },
    ),
  ],
  borderRadius: Dx(4.0),
  pieOffset: 12,
  thickness: ThicknessData(
    size: Dx(20),
    color: chartLightColor,
    align: ThicknessData.alignOutside,
  ),
);


final bigPieT = PieData(
  pies: [
    DataPoint(x: 100.0, y: 0, dy: pi / 3.0),
    DataPoint(
      x: 100.0,
      y: pi / 3.0,
      dy: pi / 3.0,
      data: {
        IThicknessOverride: ThicknessOverride(
          size: Dx(30),
          align: ThicknessData.alignOutside,
          color: chartSecondaryColor,
        ),
      },
    ),
    DataPoint(
      x: 100.0,
      y: 2 * pi / 3.0,
      dy: pi / 3.0,
      data: {
        IThicknessOverride: ThicknessOverride(
          size: Dx(40),
          align: ThicknessData.alignOutside,
          color: chartDarkColor,
        ),
      },
    ),
  ],
  borderRadius: Dx(4.0),
  pieOffset: 12,
  thickness: ThicknessData(
    size: Dx(20),
    color: chartLightColor,
    align: ThicknessData.alignOutside,
  ),
);


final smallPie = PieData(
  pies: [
    DataPoint(
      x: 40.0,
      y: 0,
      dy: 2 * pi,
      data: {
        IThicknessOverride: ThicknessOverride(
          color: chartPaleColor,
        ),
      },
    ),
    DataPoint(
      x: 60.0,
      y: 0,
      dy: pi,
      data: {
        IThicknessOverride: ThicknessOverride(
          color: chartPaleColor,
        ),
      },
    ),
    DataPoint(
      x: 80.0,
      y: 0,
      dy: pi,
      data: {
        IThicknessOverride: ThicknessOverride(
          color: chartPaleColor,
        ),
      },
    ),
    DataPoint(x: 40.0, y: pi - pi / 2.0, dy: pi / 2.0),
    DataPoint(
      x: 60.0,
      y: pi - pi / 3.0,
      dy: pi / 3.0,
      data: {
        IThicknessOverride: ThicknessOverride(
          color: chartSecondaryColor,
        ),
      },
    ),
    DataPoint(
      x: 80.0,
      y: pi - pi / 3.0,
      dy: pi / 3.0,
      data: {
        IThicknessOverride: ThicknessOverride(
          color: chartDarkColor,
        ),
      },
    ),
  ],
  borderRadius: Dx(6.0),
  thickness: ThicknessData(
    size: Dx(12),
    color: chartLightColor,
  ),
);


final smallPieT = PieData(
  pies: [
    DataPoint(
      x: 40.0,
      y: 0,
      dy: 2 * pi,
      data: {
        IThicknessOverride: ThicknessOverride(
          color: chartPaleColor
        ),
      },
    ),
    DataPoint(
      x: 60.0,
      y: 0,
      dy: pi,
      data: {
        IThicknessOverride: ThicknessOverride(
          color: chartPaleColor,
        ),
      },
    ),
    DataPoint(
      x: 80.0,
      y: 0,
      dy: pi,
      data: {
        IThicknessOverride: ThicknessOverride(
          color: chartPaleColor,
        ),
      },
    ),
    DataPoint(x: 40.0, y:pi / 4.0, dy:  pi - pi / 4.0),
    DataPoint(
      x: 60.0,
      y: pi / 3.0,
      dy: pi - pi / 3.0,
      data: {
        IThicknessOverride: ThicknessOverride(
          color: chartSecondaryColor,
        ),
      },
    ),
    DataPoint(
      x: 80.0,
      y: pi / 6.0,
      dy: pi - pi / 6.0,
      data: {
        IThicknessOverride: ThicknessOverride(
          color: chartDarkColor,
        ),
      },
    ),
  ],
  borderRadius: Dx(6.0),
  thickness: ThicknessData(
    size: Dx(12),
    color: chartLightColor,
  ),
);


final dxPie = PieData(
  origin: Offset(115, 130),
  flip: ChartFlip.acrossY,
  rotation: ChartRotation.d90,
  pies: [
    DataPoint(
      x: 7.0,
      y: pi/2 - pi/6,
      dy: 2 * pi - (pi/2 - pi/6),
      data: {
        IThicknessOverride: ThicknessOverride(
          color: chartPaleColor,
        ),
        IPieOffset: PieOffset(0.0),
      },
    ),
    DataPoint(
      x: 7.0,
      y: 0,
      dy: pi/2 - pi/6,
      data: {
        IPieOffset: PieOffset(4.0),
        IDataPointBorder: DataPointBorder(borderRadius: Dx(4.0))
      }
    ),
  ],
  borderRadius: Dx(2.0),
  thickness: ThicknessData(
    size: Dx(26),
    color: chartMainColor,
  ),
);


final dxPieT = PieData(
  origin: Offset(115, 130),
  flip: ChartFlip.acrossY,
  rotation: ChartRotation.d90,
  pies: [
    DataPoint(
      x: 7.0,
      y: pi + pi/2,
      dy: pi/2,
      data: {
        IPieOffset: PieOffset(4.0),
        IThicknessOverride: ThicknessOverride(
          color: chartPaleColor,
        )
      }
    ),
    DataPoint(
      x: 7.0,
      y: 0,
      dy: pi + pi/2,
      data: {
        IPieOffset: PieOffset(0.0),
      }
    ),
  ],
  borderRadius: Dx(3.0),
  thickness: ThicknessData(
    size: Dx(26),
    color: chartMainColor,
  ),
);


final padPie = PieData(
  pies: [
    DataPoint(
      x: 18.0,
      y: pi/2,
      dy: pi + pi/3,
      data: {
        IThicknessOverride: ThicknessOverride(
          color: chartPaleColor,
        ),
      },
    ),
    DataPoint(
      x: 18.0,
      y: -pi/6,
      dy: pi - pi/3,
    ),
  ],
  borderRadius: Dx(3.0),
  padAngle: pi / 30,
  thickness: ThicknessData(
    size: Dx(16),
    color: chartMainColor,
  ),
);


final padPieT = PieData(
  pies: [
    DataPoint(
      x: 18.0,
      y: pi/2,
      dy: pi/2,
      data: {
        IThicknessOverride: ThicknessOverride(
          color: chartPaleColor,
        ),
      },
    ),
    DataPoint(
      x: 18.0,
      y: -pi,
      dy: pi + pi/2,
    ),
  ],
  borderRadius: Dx(3.0),
  padAngle: pi / 30,
  thickness: ThicknessData(
    size: Dx(16),
    color: chartMainColor,
  ),
);

final steppedLine = LineData(
    origin: const Offset(0, -140),
    lineType: SteppedLineData.middle(isStrokeCapRound: true, isStrokeJoinRound: true),
    pointStyle: CircleDataPointStyle(radius: Dx(5), color: chartDarkColor),
    thickness: ThicknessData(size: Dx(5), color: chartMainColor),
    areaGradient: LinearGradient(colors: [chartSoftColor, chartSoftColor.withValues(alpha: 0)], begin: AlignmentGeometry.topCenter, end: AlignmentGeometry.bottomCenter),
    line: [
  DataPoint(x: -150, dy: 0),
  DataPoint(x: -130, dy: 120),
  DataPoint(x: -100, dy: 40),
  DataPoint(x: -70, dy: 95),
  DataPoint(x: -45, dy: 80),
  DataPoint(x: -20, dy: 20),
    DataPoint(x: 0, dy: 0),
]);

final steppedLineT = LineData(
  origin: const Offset(0, -140),
  lineType: SteppedLineData.middle(isStrokeCapRound: true, isStrokeJoinRound: true),
  pointStyle: CircleDataPointStyle(radius: Dx(5), color: chartMainColor),
  thickness: ThicknessData(size: Dx(5), color: chartMainColor),
  areaGradient: LinearGradient(colors: [chartSoftColor, chartSoftColor.withValues(alpha: 0)], begin: AlignmentGeometry.topCenter, end: AlignmentGeometry.bottomCenter),
  line: [
    DataPoint(x: -150, dy: 0),
    DataPoint(x: -130, dy: 20),
    DataPoint(x: -100, dy: 80),
    DataPoint(x: -70, dy: 10),
    DataPoint(x: -45, dy: 50),
    DataPoint(x: -20, dy: 70),
    DataPoint(x: 0, dy: 0),
]);


final lineTop = LineData(
    origin: const Offset(150, -150),
    lineType: CurvedLineData(isStrokeCapRound: true, isStrokeJoinRound: true, smoothness: 1.0),
    thickness: ThicknessData(size: Dx(5), color: chartMainColor),
    line: [
      DataPoint(x: -140, dy: 90),
      DataPoint(x: -100, dy: 20),
      DataPoint(x: -50, dy: 100),
      DataPoint(x: -10, dy: 20),
    ]);

final lineBottom = LineData(
    origin: const Offset(150, -150),
    lineType: CurvedLineData(isStrokeCapRound: true, isStrokeJoinRound: true, smoothness: 1.0),
    thickness: ThicknessData(size: Dx(5), color: chartDarkColor),
    line: [
      DataPoint(x: -140, dy: 20),
      DataPoint(x: -100, dy: 80),
      DataPoint(x: -50, dy: 40),
      DataPoint(x: -10, dy: 90),
    ]);

final between = BetweenLineData(
    origin: const Offset(150, -150),
    from: lineTop,
    to: lineBottom,
  areaColor: chartPaleColor
);

final lineTopT = LineData(
    origin: const Offset(150, -150),
    lineType: CurvedLineData(isStrokeCapRound: true, isStrokeJoinRound: true, smoothness: 1.0),
    thickness: ThicknessData(size: Dx(5), color: chartMainColor),
    line: [
      DataPoint(x: -140, dy: 20),
      DataPoint(x: -100, dy: 80),
      DataPoint(x: -50, dy: 40),
      DataPoint(x: -10, dy: 90),
    ]);

final lineBottomT = LineData(
    origin: const Offset(150, -150),
    lineType: CurvedLineData(isStrokeCapRound: true, isStrokeJoinRound: true, smoothness: 1.0),
    thickness: ThicknessData(size: Dx(5), color: chartDarkColor),
    line: [
      DataPoint(x: -140, dy: 90),
      DataPoint(x: -100, dy: 20),
      DataPoint(x: -50, dy: 100),
      DataPoint(x: -10, dy: 20),
    ]);

final betweenT = BetweenLineData(
    origin: const Offset(150, -150),
    from: lineTopT,
    to: lineBottomT,
    areaColor: chartPaleColor
);

const DataPointDataMap barsData = {
  IThicknessOverride: ThicknessOverride(color: chartMainColor)
};

final bars = BarData(
    origin: const Offset(-150, 100),
    thickness: ThicknessData(size: Dx(12), color: chartDarkColor),
    borderRadius: Dx(4),
    bars: [

      DataPoint(x: 10, dy: 50),
      DataPoint(x: 30, y: 10, dy: 40),
      DataPoint(x: 50, y: 20, dy: 30),
      DataPoint(x: 70, y: 30, dy: 20),
      DataPoint(x: 90, y: 40, dy: 10),

      DataPoint(x: 10, y: -80, dy: 70, data: barsData),
      DataPoint(x: 30, y: -50, dy: 50, data: barsData),
      DataPoint(x: 50, y: -20, dy: 30, data: barsData),
      DataPoint(x: 70, y: 0, dy: 20, data: barsData),
      DataPoint(x: 90, y: 20, dy: 10, data: barsData),
    ]);


final barsT = BarData(
    origin: const Offset(-150, 100),
    thickness: ThicknessData(size: Dx(12), color: chartDarkColor),
    borderRadius: Dx(4),
    bars: [

      DataPoint(x: 10, y: 40, dy: 10),
      DataPoint(x: 30, y: 42, dy: 8),
      DataPoint(x: 50, y: 44, dy: 6),
      DataPoint(x: 70, y: 46, dy: 4),
      DataPoint(x: 90, y: 48, dy: 2),

      DataPoint(x: 10, y: 40-16, dy: 14, data: barsData),
      DataPoint(x: 30, y: 40-10, dy: 10, data: barsData),
      DataPoint(x: 50, y: 40-4, dy: 6, data: barsData),
      DataPoint(x: 70, y: 40, dy: 4, data: barsData),
      DataPoint(x: 90, y: 44, dy: 2, data: barsData),
    ]);


const chairAvailableStyle = ChairDataPointStyle(
  size: Dx(0.72),
  backColor: chartDarkColor,
  baseColor: chartLightColor,
);

const chairBookedStyle = ChairDataPointStyle(
  size: Dx(0.72),
  backColor: bookedDarkColor,
  baseColor: bookedLightColor,
);

const chairExtent = ChartInsets.all(Dx(0.36));

final chairSeats = DataPointPipeline()
    .seats(style: chairAvailableStyle, extent: chairExtent)
    .seats(
      selector: SeatSelector(rows: {2, 5, 7, 10}, columns: {2, 4}),
      style: chairBookedStyle,
    )
    .build(
      SeatsBuilder(
        seatDx: 1.0,
        rowDy: 1.0,
        gapDx: 0.12,
        gapDy: 0.12,
      )
          .record()
          .seats(2)
          .skip()
          .seats(2)
          .nextRow()
          .saveRecord(key: 'chairSection')
          .repeat(3, key: 'chairSection')
          .nextRow()
          .repeat(3, key: 'chairSection')
          .nextRow()
          .repeat(3, key: 'chairSection')
          .build(),
    );

final chairSeatChart = LineData.scatter(points: chairSeats);

const circleFirstBlockStyle = CircleDataPointStyle(
  radius: Dx(0.28),
  color: chartDarkColor,
);

const circleSecondBlockStyle = CircleDataPointStyle(
  radius: Dx(0.28),
  color: chartMainColor,
);

const circleThirdBlockStyle = CircleDataPointStyle(
  radius: Dx(0.28),
  color: chartLightColor,
);

const circleBookedStyle = CircleDataPointStyle(
  radius: Dx(0.28),
  color: bookedColor,
);

final circleSeats = DataPointPipeline()
    .seats(style: circleFirstBlockStyle, extent: circleFirstBlockStyle.extent)
    .seats(selector: SeatSelector(rows: {4, 5, 6, 7}), style: circleSecondBlockStyle)
    .seats(selector: SeatSelector(rows: {9, 10, 11}), style: circleThirdBlockStyle)
    .seats(predicate: (_, key) => (key.row + key.column) % 5 == 0, style: circleBookedStyle)
    .build(
      SeatsBuilder(
        seatDx: 1.0,
        rowDy: 1.0,
        gapDx: 0.12,
        gapDy: 0.12,
      )
          .record()
          .seats(8)
          .nextRow()
          .repeat(2)
          .nextRow()
          .record()
          .skip()
          .seats(6)
          .nextRow()
          .repeat(4)
          .nextRow()
          .record()
          .skip(2)
          .seats(4)
          .nextRow()
          .repeat(3)
          .build(),
    );

final circleSeatChart = LineData.scatter(points: circleSeats);

const userDarkStyle = UserDataPointStyle(
  height: Dx(0.78),
  color: chartDarkColor,
);

const userLightStyle = UserDataPointStyle(
  height: Dx(0.78),
  color: chartLightColor,
);

const userRows = 5;
const userColumns = 8;
const userDarkSeats = 19;

const userSeatExtent = ChartInsets(
  left: Dx(0.19),
  top: Dx(0.39),
  right: Dx(0.19),
  bottom: Dx(0.39),
);

final userSeats = DataPointPipeline()
    .seats(style: userLightStyle, extent: userSeatExtent)
    .seats(predicate: (_, key) => (userRows - key.row) * userColumns + key.column <= userDarkSeats, style: userDarkStyle)
    .build(
      SeatsBuilder(
        seatDx: 0.6,
        rowDy: 1.0,
      )
          .record()
          .seats(userColumns)
          .nextRow()
          .repeat(userRows)
          .build(),
    );

final userSeatChart = LineData.scatter(points: userSeats);

const weightedScatterSource = [
  DataPoint(x: 0.0, y: 0.8, dy: 0.0, z: 2.0),
  DataPoint(x: 0.8, y: 3.2, dy: 0.0, z: 7.0),
  DataPoint(x: 1.8, y: 1.7, dy: 0.0, z: 4.0),
  DataPoint(x: 2.5, y: 4.4, dy: 0.0, z: 10.0),
  DataPoint(x: 3.4, y: 2.8, dy: 0.0, z: 5.0),
  DataPoint(x: 4.2, y: 0.6, dy: 0.0, z: 8.0),
  DataPoint(x: 5.0, y: 3.8, dy: 0.0, z: 3.0),
  DataPoint(x: 5.8, y: 2.0, dy: 0.0, z: 9.0),
  DataPoint(x: 6.7, y: 4.6, dy: 0.0, z: 6.0),
  DataPoint(x: 7.6, y: 1.0, dy: 0.0, z: 11.0),
  DataPoint(x: 8.5, y: 3.0, dy: 0.0, z: 2.5),
  DataPoint(x: 9.4, y: 4.2, dy: 0.0, z: 8.5),
  DataPoint(x: 10.2, y: 1.9, dy: 0.0, z: 4.5),
  DataPoint(x: 11.0, y: 3.6, dy: 0.0, z: 7.5),
  DataPoint(x: 12.0, y: 0.7, dy: 0.0, z: 6.5),
];

const weightedScatterMinStyle = CircleDataPointStyle(radius: Vmin(2.5), color: chartSoftColor);
const weightedScatterMaxStyle = CircleDataPointStyle(radius: Vmin(8.0), color: chartDarkColor);

final weightedScatter = DataPointPipeline()
    .rescaleZ()
    .scatterZ(
      style: (
        min: weightedScatterMinStyle,
        max: weightedScatterMaxStyle,
      ),
      extent: (
        min: weightedScatterMinStyle.extent,
        max: weightedScatterMaxStyle.extent,
      ),
    )
    .build(weightedScatterSource);

final weightedScatterChart = LineData.scatter(points: weightedScatter);

class _ExamplePageState extends State<_ExamplePage> {

  bool _toggled = false;

  static final _initialCharts = [
    bigPie, steppedLine, smallPie, between, lineTop, lineBottom, dxPie, padPie, bars
  ];

  static final _toggleCharts = [
    bigPieT, steppedLineT, smallPieT, betweenT, lineTopT, lineBottomT, dxPieT, padPieT, barsT
  ];

  Widget _panel(Widget chart) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: chart,
    );
  }

  @override
  Widget build(BuildContext context) {

    final charts = _toggled ? _toggleCharts : _initialCharts;

    return Scaffold(
      body: GestureDetector(
        onTap: () => setState(() => _toggled = !_toggled),
        child: Container(
          padding: EdgeInsets.only(top: 60, bottom: 30, left: 30, right: 30),
          decoration: BoxDecoration(
            border: Border.all(color: frameColor),
            borderRadius: BorderRadius.circular(8),
          ),
          alignment: Alignment.center,
          child: AspectRatio(
            aspectRatio: 1.0,
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Column(
                    children: [
                      Expanded(
                        flex: 3,
                        child: _panel(SparklinesChart(
                          aspectRatio: 1.0,
                          animate: true,
                          layout: const RelativeLayout(
                            minX: -150.0,
                            maxX: 150.0,
                            minY: -150.0,
                            maxY: 150.0,
                          ),
                          charts: charts,
                        )),
                      ),
                      Expanded(
                        child: _panel(SparklinesChart(
                          animate: false,
                          crop: true,
                          padding: ChartInsets.all(Px(20.0)),
                          layout: const RelativeLayout.full(),
                          charts: [weightedScatterChart],
                        )),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      Expanded(
                        child: _panel(SparklinesChart(
                          aspectRatio: 0.6,
                          animate: false,
                          crop: true,
                          layout: const RelativeLayout.full(),
                          charts: [chairSeatChart],
                        )),
                      ),
                      Expanded(
                        child: _panel(SparklinesChart(
                          animate: false,
                          crop: true,
                          layout: const RelativeLayout.full(),
                          charts: [circleSeatChart],
                        )),
                      ),
                      Expanded(
                        child: _panel(SparklinesChart(
                          animate: false,
                          crop: true,
                          layout: const RelativeLayout.full(),
                          padding: ChartInsets.vertical(Dy(0.6)),
                          charts: [userSeatChart],
                        )),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sparklines Example',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: chartMainColor),
        useMaterial3: true,
      ),
      home: const _ExamplePage(),
    );
  }
}

class _ExamplePage extends StatefulWidget {
  const _ExamplePage();

  @override
  State<_ExamplePage> createState() => _ExamplePageState();
}

const chartDarkColor = Color(0xff0d47a1);
const chartSecondaryColor = Color(0xff1e88e5);
const chartMainColor = Color(0xff2196f3);
const chartLightColor = Color(0xff64b5f6);
const chartSoftColor = Color(0xff90caf9);
const chartPaleColor = Color(0xffbbdefb);
const bookedDarkColor = Color(0xff9e9e9e);
const bookedColor = Color(0xffbdbdbd);
const bookedLightColor = Color(0xffbdbdbd);
const frameColor = Color(0xffe0e0e0);

class ChairDataPointStyle extends ADataPointData<ChairDataPointStyle> implements IDataPointStyle {

  static const IDataPointRenderer defaultRenderer = ChairDataPointRenderer();

  final ILengthValue size;
  final Color backColor;
  final Color baseColor;

  const ChairDataPointStyle({
    required this.size,
    required this.backColor,
    required this.baseColor,
  });

  @override
  ChairDataPointStyle lerp(ChairDataPointStyle next, double t) {
    return ChairDataPointStyle(
      size: ILengthValue.lerp(size, next.size, t)!,
      backColor: Color.lerp(backColor, next.backColor, t) ?? next.backColor,
      baseColor: Color.lerp(baseColor, next.baseColor, t) ?? next.baseColor,
    );
  }

  @override
  IDataPointRenderer get renderer => defaultRenderer;

}

class ChairDataPointRenderer implements IDataPointRenderer {

  const ChairDataPointRenderer();

  @override
  void render(Canvas canvas, ChartTransform transform, Paint paint, IDataPointStyle style, Object dataPoint) {
    final chairStyle = style as ChairDataPointStyle;
    final point = dataPoint as DataPoint;
    final size = transform.length(chairStyle.size);
    if (!size.isFinite || size <= 0.0) return;

    final center = transform.xy(point.x, point.fy);
    final top = center.dy - size / 2.0;
    final backBottomRadius = Radius.circular(size * 0.09);
    final back = RRect.fromRectAndCorners(
      Rect.fromLTWH(center.dx - size * 0.39, top, size * 0.78, size * 0.82),
      topLeft: Radius.circular(size * 0.24),
      topRight: Radius.circular(size * 0.24),
      bottomLeft: backBottomRadius,
      bottomRight: backBottomRadius,
    );
    final base = RRect.fromRectAndCorners(
      Rect.fromLTWH(center.dx - size / 2.0, top + size * 0.70, size, size * 0.30),
      topLeft: Radius.circular(size * 0.07),
      topRight: Radius.circular(size * 0.07),
      bottomLeft: backBottomRadius,
      bottomRight: backBottomRadius,
    );

    paint
      ..style = PaintingStyle.fill
      ..shader = null
      ..color = chairStyle.backColor;
    canvas.drawRRect(back, paint);
    paint.color = chairStyle.baseColor;
    canvas.drawRRect(base, paint);
  }

}

@immutable
class UserProportions {

  final double headOffset;
  final double headSize;
  final double bodyOffset;
  final double bodyHeight;
  final double bodyWidth;
  final double bodyRadius;
  final double legsOffset;
  final double legsHeight;
  final double legsWidth;
  final double legsRadius;

  const UserProportions({
    this.headOffset = 0.0,
    this.headSize = 0.18,
    double? bodyOffset,
    this.bodyHeight = 0.32,
    this.bodyWidth = 0.44,
    this.bodyRadius = 0.08,
    double? legsOffset,
    this.legsHeight = 0.42,
    this.legsWidth = 0.18,
    this.legsRadius = 0.05,
  }) :
        bodyOffset = bodyOffset ?? headOffset + headSize + 0.04,
        legsOffset = legsOffset ?? (bodyOffset ?? headOffset + headSize + 0.04) + bodyHeight + 0.04;

  const UserProportions.solid({
    this.headOffset = 0.0,
    this.headSize = 0.18,
    double? bodyOffset,
    this.bodyHeight = 0.32,
    this.bodyWidth = 0.44,
    this.bodyRadius = 0.08,
    this.legsHeight = 0.42,
    this.legsWidth = 0.18,
    this.legsRadius = 0.05,
  }) :
        bodyOffset = bodyOffset ?? headOffset + headSize + 0.04,
        legsOffset = (bodyOffset ?? headOffset + headSize + 0.04) + bodyHeight / 2.0;

  UserProportions lerp(UserProportions next, double t) {
    double value(double from, double to) => from + (to - from) * t;
    return UserProportions(
      headOffset: value(headOffset, next.headOffset),
      headSize: value(headSize, next.headSize),
      bodyOffset: value(bodyOffset, next.bodyOffset),
      bodyHeight: value(bodyHeight, next.bodyHeight),
      bodyWidth: value(bodyWidth, next.bodyWidth),
      bodyRadius: value(bodyRadius, next.bodyRadius),
      legsOffset: value(legsOffset, next.legsOffset),
      legsHeight: value(legsHeight, next.legsHeight),
      legsWidth: value(legsWidth, next.legsWidth),
      legsRadius: value(legsRadius, next.legsRadius),
    );
  }

}

class UserDataPointStyle extends ADataPointData<UserDataPointStyle> implements IDataPointStyle {

  static const IDataPointRenderer defaultRenderer = UserDataPointRenderer();

  final ILengthValue height;
  final Color color;
  final UserProportions proportions;

  const UserDataPointStyle({
    required this.height,
    required this.color,
    this.proportions = const UserProportions(),
  });

  @override
  UserDataPointStyle lerp(UserDataPointStyle next, double t) {
    return UserDataPointStyle(
      height: ILengthValue.lerp(height, next.height, t)!,
      color: Color.lerp(color, next.color, t) ?? next.color,
      proportions: proportions.lerp(next.proportions, t),
    );
  }

  @override
  IDataPointRenderer get renderer => defaultRenderer;

}

class UserDataPointRenderer implements IDataPointRenderer {

  const UserDataPointRenderer();

  @override
  void render(Canvas canvas, ChartTransform transform, Paint paint, IDataPointStyle style, Object dataPoint) {
    final userStyle = style as UserDataPointStyle;
    final point = dataPoint as DataPoint;
    final height = transform.length(userStyle.height);
    if (!height.isFinite || height <= 0.0) return;

    final center = transform.xy(point.x, point.fy);
    final proportions = userStyle.proportions;
    final top = center.dy - height / 2.0;
    final headSize = height * proportions.headSize;
    final body = RRect.fromRectAndRadius(
      Rect.fromLTWH(center.dx - height * proportions.bodyWidth / 2.0, top + height * proportions.bodyOffset, height * proportions.bodyWidth, height * proportions.bodyHeight),
      Radius.circular(height * proportions.bodyRadius),
    );
    final legs = RRect.fromRectAndRadius(
      Rect.fromLTWH(center.dx - height * proportions.legsWidth / 2.0, top + height * proportions.legsOffset, height * proportions.legsWidth, height * proportions.legsHeight),
      Radius.circular(height * proportions.legsRadius),
    );

    paint
      ..style = PaintingStyle.fill
      ..shader = null
      ..color = userStyle.color;
    canvas.drawCircle(Offset(center.dx, top + height * proportions.headOffset + headSize / 2.0), headSize / 2.0, paint);
    canvas.drawRRect(body, paint);
    canvas.drawRRect(legs, paint);
  }

}
