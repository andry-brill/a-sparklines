import 'dart:math';

import 'package:flutter/material.dart';
import 'package:any_sparklines/any_sparklines.dart';


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

class UserDataPointStyle extends ADataPointData<UserDataPointStyle> implements IDataPointStyle {

  static const IDataPointRenderer defaultRenderer = UserDataPointRenderer();

  final ILengthValue size;
  final Color color;

  const UserDataPointStyle({
    required this.size,
    required this.color,
  });

  @override
  UserDataPointStyle lerp(UserDataPointStyle next, double t) {
    return UserDataPointStyle(
      size: ILengthValue.lerp(size, next.size, t)!,
      color: Color.lerp(color, next.color, t) ?? next.color,
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
    final size = transform.length(userStyle.size);
    if (!size.isFinite || size <= 0.0) return;

    final center = transform.xy(point.x, point.fy);
    final top = center.dy - size / 2.0;
    final headRadius = size * 0.135;
    final bodyAndLegsTop = top + headRadius * 2.0 + size * 0.06;
    final bodyAndLegsHeight = size * 0.67;
    final bodyHeight = bodyAndLegsHeight * 0.45;
    final legsHeight = bodyAndLegsHeight - bodyHeight;
    final body = RRect.fromRectAndRadius(
      Rect.fromLTWH(center.dx - size * 0.39, bodyAndLegsTop, size * 0.78, bodyHeight),
      Radius.circular(size * 0.12),
    );
    final legs = RRect.fromRectAndRadius(
      Rect.fromLTWH(center.dx - size * 0.20, bodyAndLegsTop + bodyHeight, size * 0.40, legsHeight),
      Radius.circular(size * 0.09),
    );

    paint
      ..style = PaintingStyle.fill
      ..shader = null
      ..color = userStyle.color;
    canvas.drawCircle(Offset(center.dx, top + headRadius), headRadius, paint);
    canvas.drawRRect(body, paint);
    canvas.drawRRect(legs, paint);
  }

}

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
          color: Colors.blue.shade600,
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
          color: Colors.blue.shade900,
        ),
      },
    ),
  ],
  borderRadius: Dx(4.0),
  pieOffset: 12,
  thickness: ThicknessData(
    size: Dx(20),
    color: Colors.blue.shade300,
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
          color: Colors.blue.shade600,
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
          color: Colors.blue.shade900,
        ),
      },
    ),
  ],
  borderRadius: Dx(4.0),
  pieOffset: 12,
  thickness: ThicknessData(
    size: Dx(20),
    color: Colors.blue.shade300,
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
          color: Colors.blue.shade100,
        ),
      },
    ),
    DataPoint(
      x: 60.0,
      y: 0,
      dy: pi,
      data: {
        IThicknessOverride: ThicknessOverride(
          color: Colors.blue.shade100,
        ),
      },
    ),
    DataPoint(
      x: 80.0,
      y: 0,
      dy: pi,
      data: {
        IThicknessOverride: ThicknessOverride(
          color: Colors.blue.shade100,
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
          color: Colors.blue.shade600,
        ),
      },
    ),
    DataPoint(
      x: 80.0,
      y: pi - pi / 3.0,
      dy: pi / 3.0,
      data: {
        IThicknessOverride: ThicknessOverride(
          color: Colors.blue.shade900,
        ),
      },
    ),
  ],
  borderRadius: Dx(6.0),
  thickness: ThicknessData(
    size: Dx(12),
    color: Colors.blue.shade300,
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
          color: Colors.blue.shade100
        ),
      },
    ),
    DataPoint(
      x: 60.0,
      y: 0,
      dy: pi,
      data: {
        IThicknessOverride: ThicknessOverride(
          color: Colors.blue.shade100,
        ),
      },
    ),
    DataPoint(
      x: 80.0,
      y: 0,
      dy: pi,
      data: {
        IThicknessOverride: ThicknessOverride(
          color: Colors.blue.shade100,
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
          color: Colors.blue.shade600,
        ),
      },
    ),
    DataPoint(
      x: 80.0,
      y: pi / 6.0,
      dy: pi - pi / 6.0,
      data: {
        IThicknessOverride: ThicknessOverride(
          color: Colors.blue.shade900,
        ),
      },
    ),
  ],
  borderRadius: Dx(6.0),
  thickness: ThicknessData(
    size: Dx(12),
    color: Colors.blue.shade300,
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
          color: Colors.blue.shade100,
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
    color: Colors.blue,
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
          color: Colors.blue.shade100,
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
    color: Colors.blue,
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
          color: Colors.blue.shade100,
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
    color: Colors.blue,
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
          color: Colors.blue.shade100,
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
    color: Colors.blue,
  ),
);

final steppedLine = LineData(
    origin: const Offset(0, -140),
    lineType: SteppedLineData.middle(isStrokeCapRound: true, isStrokeJoinRound: true),
    pointStyle: CircleDataPointStyle(radius: Dx(5), color: Colors.blue.shade900),
    thickness: ThicknessData(size: Dx(5), color: Colors.blue),
    areaGradient: LinearGradient(colors: [Colors.blue.shade200, Colors.blue.shade200.withValues(alpha: 0)], begin: AlignmentGeometry.topCenter, end: AlignmentGeometry.bottomCenter),
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
  pointStyle: CircleDataPointStyle(radius: Dx(5), color: Colors.blue),
  thickness: ThicknessData(size: Dx(5), color: Colors.blue),
  areaGradient: LinearGradient(colors: [Colors.blue.shade200, Colors.blue.shade200.withValues(alpha: 0)], begin: AlignmentGeometry.topCenter, end: AlignmentGeometry.bottomCenter),
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
    thickness: ThicknessData(size: Dx(5), color: Colors.blue),
    line: [
      DataPoint(x: -140, dy: 90),
      DataPoint(x: -100, dy: 20),
      DataPoint(x: -50, dy: 100),
      DataPoint(x: -10, dy: 20),
    ]);

final lineBottom = LineData(
    origin: const Offset(150, -150),
    lineType: CurvedLineData(isStrokeCapRound: true, isStrokeJoinRound: true, smoothness: 1.0),
    thickness: ThicknessData(size: Dx(5), color: Colors.blue.shade900),
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
  areaColor: Colors.blue.shade100
);

final lineTopT = LineData(
    origin: const Offset(150, -150),
    lineType: CurvedLineData(isStrokeCapRound: true, isStrokeJoinRound: true, smoothness: 1.0),
    thickness: ThicknessData(size: Dx(5), color: Colors.blue),
    line: [
      DataPoint(x: -140, dy: 20),
      DataPoint(x: -100, dy: 80),
      DataPoint(x: -50, dy: 40),
      DataPoint(x: -10, dy: 90),
    ]);

final lineBottomT = LineData(
    origin: const Offset(150, -150),
    lineType: CurvedLineData(isStrokeCapRound: true, isStrokeJoinRound: true, smoothness: 1.0),
    thickness: ThicknessData(size: Dx(5), color: Colors.blue.shade900),
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
    areaColor: Colors.blue.shade100
);

const DataPointDataMap barsData = {
  IThicknessOverride: ThicknessOverride(color: Colors.blue)
};

final bars = BarData(
    origin: const Offset(-150, 100),
    thickness: ThicknessData(size: Dx(12), color: Colors.blue.shade900),
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
    thickness: ThicknessData(size: Dx(12), color: Colors.blue.shade900),
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


const chairStyle = ChairDataPointStyle(
  size: Dx(0.72),
  backColor: Color(0xff315f96),
  baseColor: Color(0xff78a9dc),
);

const chairExtent = ChartInsets(
  left: Dx(0.36),
  top: Dx(0.36),
  right: Dx(0.36),
  bottom: Dx(0.36),
);

final chairSeats = DataPointPipeline()
    .seats(style: chairStyle, extent: chairExtent)
    .build(
      SeatsBuilder(
        seatDx: 1.0,
        rowDy: 1.0,
        gapDx: 0.12,
        gapDy: 0.12,
      )
          .record(key: 'chairSection')
          .seats(3)
          .skip(2)
          .seats(3)
          .nextRow()
          .repeat(3)
          .nextRow()
          .repeat(3, key: 'chairSection')
          .nextRow()
          .repeat(3, key: 'chairSection')
          .build(),
    );

final chairSeatChart = LineData.scatter(points: chairSeats);

const circleSeatStyle = CircleDataPointStyle(
  radius: Dx(0.28),
  color: Color(0xff42a5a5),
);

const circleSeatExtent = ChartInsets(
  left: Dx(0.28),
  top: Dx(0.28),
  right: Dx(0.28),
  bottom: Dx(0.28),
);

final circleSeats = DataPointPipeline()
    .seats(style: circleSeatStyle, extent: circleSeatExtent)
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

const userSeatStyle = UserDataPointStyle(
  size: Dx(0.72),
  color: Color(0xff7357a6),
);

const userSeatExtent = ChartInsets(
  left: Dx(0.36),
  top: Dx(0.36),
  right: Dx(0.36),
  bottom: Dx(0.36),
);

final userSeats = DataPointPipeline()
    .seats(style: userSeatStyle, extent: userSeatExtent)
    .build(
      SeatsBuilder(
        seatDx: 1.0,
        rowDy: 1.0,
        gapDx: 0.15,
        gapDy: 0.15,
      )
          .record()
          .seats(5)
          .nextRow()
          .repeat(5)
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

final weightedScatter = DataPointPipeline()
    .rescaleZ()
    .scatterZ(
      style: (
        min: const CircleDataPointStyle(radius: Vmin(2.5), color: Color(0xff90caf9)),
        max: const CircleDataPointStyle(radius: Vmin(8.0), color: Color(0xff3949ab)),
      ),
      extent: (
        min: const ChartInsets(left: Vmin(2.5), top: Vmin(2.5), right: Vmin(2.5), bottom: Vmin(2.5)),
        max: const ChartInsets(left: Vmin(8.0), top: Vmin(8.0), right: Vmin(8.0), bottom: Vmin(8.0)),
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
      padding: const EdgeInsets.all(5.0),
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
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          alignment: Alignment.center,
          child: AspectRatio(
            aspectRatio: 1.0,
            child: Column(
              children: [
                Expanded(
                  flex: 2,
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
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
                        child: Column(
                          children: [
                            Expanded(
                              child: _panel(SparklinesChart(
                                aspectRatio: 1.0,
                                animate: false,
                                crop: true,
                                layout: const RelativeLayout.full(),
                                charts: [chairSeatChart],
                              )),
                            ),
                            Expanded(
                              child: _panel(SparklinesChart(
                                aspectRatio: 1.0,
                                animate: false,
                                crop: true,
                                layout: const RelativeLayout.full(),
                                charts: [circleSeatChart],
                              )),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: _panel(SparklinesChart(
                          aspectRatio: 2.0,
                          animate: false,
                          crop: true,
                          layout: const RelativeLayout.full(),
                          charts: [weightedScatterChart],
                        )),
                      ),
                      Expanded(
                        child: _panel(SparklinesChart(
                          aspectRatio: 1.0,
                          animate: false,
                          crop: true,
                          layout: const RelativeLayout.full(),
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
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
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
