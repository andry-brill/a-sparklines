import 'dart:math';

import 'package:flutter/material.dart';
import 'package:any_sparklines/any_sparklines.dart';

final bigPie = PieData(
  points: [
    DataPoint(x: 100.0, y: 0, dy: pi / 6.0),
    DataPoint(
      x: 100.0,
      y: pi / 6.0,
      dy: pi / 6.0,
      thickness: ThicknessOverride(
        size: 30,
        align: ThicknessData.alignOutside,
        color: Colors.blue.shade600,
      ),
    ),
    DataPoint(
      x: 100.0,
      y: pi / 3.0,
      dy: pi / 6.0,
      thickness: ThicknessOverride(
        size: 40,
        align: ThicknessData.alignOutside,
        color: Colors.blue.shade900,
      ),
    ),
  ],
  borderRadius: 4.0,
  space: 12,
  thickness: ThicknessData(
    size: 20,
    color: Colors.blue.shade300,
    align: ThicknessData.alignOutside,
  ),
);


final bigPieT = PieData(
  points: [
    DataPoint(x: 100.0, y: 0, dy: pi / 3.0),
    DataPoint(
      x: 100.0,
      y: pi / 3.0,
      dy: pi / 3.0,
      thickness: ThicknessOverride(
        size: 30,
        align: ThicknessData.alignOutside,
        color: Colors.blue.shade600,
      ),
    ),
    DataPoint(
      x: 100.0,
      y: 2 * pi / 3.0,
      dy: pi / 3.0,
      thickness: ThicknessOverride(
        size: 40,
        align: ThicknessData.alignOutside,
        color: Colors.blue.shade900,
      ),
    ),
  ],
  borderRadius: 4.0,
  space: 12,
  thickness: ThicknessData(
    size: 20,
    color: Colors.blue.shade300,
    align: ThicknessData.alignOutside,
  ),
);


final smallPie = PieData(
  points: [
    DataPoint(
      x: 40.0,
      y: 0,
      dy: pi,
      thickness: ThicknessOverride(
        color: Colors.blue.shade100,
      ),
    ),
    DataPoint(
      x: 60.0,
      y: 0,
      dy: pi,
      thickness: ThicknessOverride(
        color: Colors.blue.shade100,
      ),
    ),
    DataPoint(
      x: 80.0,
      y: 0,
      dy: pi,
      thickness: ThicknessOverride(
        color: Colors.blue.shade100,
      ),
    ),
    DataPoint(x: 40.0, y: pi - pi / 2.0, dy: pi / 2.0),
    DataPoint(
      x: 60.0,
      y: pi - pi / 3.0,
      dy: pi / 3.0,
      thickness: ThicknessOverride(
        color: Colors.blue.shade600,
      ),
    ),
    DataPoint(
      x: 80.0,
      y: pi - pi / 3.0,
      dy: pi / 3.0,
      thickness: ThicknessOverride(
        color: Colors.blue.shade900,
      ),
    ),
  ],
  borderRadius: 6.0,
  thickness: ThicknessData(
    size: 12,
    color: Colors.blue.shade300,
  ),
);


final smallPieT = PieData(
  points: [
    DataPoint(
      x: 40.0,
      y: 0,
      dy: pi,
      thickness: ThicknessOverride(
        color: Colors.blue.shade100,
      ),
    ),
    DataPoint(
      x: 60.0,
      y: 0,
      dy: pi,
      thickness: ThicknessOverride(
        color: Colors.blue.shade100,
      ),
    ),
    DataPoint(
      x: 80.0,
      y: 0,
      dy: pi,
      thickness: ThicknessOverride(
        color: Colors.blue.shade100,
      ),
    ),
    DataPoint(x: 40.0, y:pi / 4.0, dy:  pi - pi / 4.0),
    DataPoint(
      x: 60.0,
      y: pi / 3.0,
      dy: pi - pi / 3.0,
      thickness: ThicknessOverride(
        color: Colors.blue.shade600,
      ),
    ),
    DataPoint(
      x: 80.0,
      y: pi / 6.0,
      dy: pi - pi / 6.0,
      thickness: ThicknessOverride(
        color: Colors.blue.shade900,
      ),
    ),
  ],
  borderRadius: 6.0,
  thickness: ThicknessData(
    size: 12,
    color: Colors.blue.shade300,
  ),
);


final steppedLine = LineData(
    origin: const Offset(0, -140),
    lineType: SteppedLineData.middle(isStrokeCapRound: true, isStrokeJoinRound: true),
    thickness: ThicknessData(size: 8, color: Colors.blue),
    areaGradient: LinearGradient(colors: [Colors.blue.shade200, Colors.blue.shade200.withValues(alpha: 0)], begin: AlignmentGeometry.topCenter, end: AlignmentGeometry.bottomCenter),
    points: [
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
  thickness: ThicknessData(size: 8, color: Colors.blue),
  areaGradient: LinearGradient(colors: [Colors.blue.shade200, Colors.blue.shade200.withValues(alpha: 0)], begin: AlignmentGeometry.topCenter, end: AlignmentGeometry.bottomCenter),
  points: [
    DataPoint(x: -150, dy: 0),
    DataPoint(x: -130, dy: 20),
    DataPoint(x: -100, dy: 80),
    DataPoint(x: -70, dy: 10),
    DataPoint(x: -45, dy: 50),
    DataPoint(x: -20, dy: 120),
    DataPoint(x: 0, dy: 0),
]);


final lineTop = LineData(
    origin: const Offset(150, -150),
    lineType: CurvedLineData(isStrokeCapRound: true, isStrokeJoinRound: true, smoothness: 1.0),
    thickness: ThicknessData(size: 8, color: Colors.blue),
    points: [
      DataPoint(x: -140, dy: 90),
      DataPoint(x: -100, dy: 20),
      DataPoint(x: -50, dy: 100),
      DataPoint(x: -10, dy: 20),
    ]);

final lineBottom = LineData(
    origin: const Offset(150, -150),
    lineType: CurvedLineData(isStrokeCapRound: true, isStrokeJoinRound: true, smoothness: 1.0),
    thickness: ThicknessData(size: 8, color: Colors.blue.shade900),
    points: [
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
    thickness: ThicknessData(size: 8, color: Colors.blue),
    points: [
      DataPoint(x: -140, dy: 20),
      DataPoint(x: -100, dy: 80),
      DataPoint(x: -50, dy: 40),
      DataPoint(x: -10, dy: 90),
    ]);

final lineBottomT = LineData(
    origin: const Offset(150, -150),
    lineType: CurvedLineData(isStrokeCapRound: true, isStrokeJoinRound: true, smoothness: 1.0),
    thickness: ThicknessData(size: 8, color: Colors.blue.shade900),
    points: [
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

final bars = BarData(
    origin: const Offset(-150, 100),
    thickness: ThicknessData(size: 24, color: Colors.blue.shade900),
    borderRadius: 8,
    bars: [

      DataPoint(x: 10, dy: 50),
      DataPoint(x: 30, y: 10, dy: 40),
      DataPoint(x: 50, y: 20, dy: 30),
      DataPoint(x: 70, y: 30, dy: 20),
      DataPoint(x: 90, y: 40, dy: 10),

      DataPoint(x: 10, y: -80, dy: 70, thickness: ThicknessOverride(color: Colors.blue)),
      DataPoint(x: 30, y: -50, dy: 50, thickness: ThicknessOverride(color: Colors.blue)),
      DataPoint(x: 50, y: -20, dy: 30, thickness: ThicknessOverride(color: Colors.blue)),
      DataPoint(x: 70, y: 0, dy: 20, thickness: ThicknessOverride(color: Colors.blue)),
      DataPoint(x: 90, y: 20, dy: 10, thickness: ThicknessOverride(color: Colors.blue)),
    ]);

class _ExamplePageState extends State<_ExamplePage> {

  bool _toggled = false;

  static final _initialCharts = [
    bigPie, steppedLine, smallPie, between, lineTop, lineBottom, bars
  ];

  static final _toggleCharts = [
    bigPieT, steppedLineT, smallPieT, betweenT, lineTopT, lineBottomT,
  ];

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
          child: SparklinesChart(
            aspectRatio: 1,
            animate: true,
            layout: const RelativeLayout(
              minX: -150.0,
              maxX: 150.0,
              minY: -150.0,
              maxY: 150.0,
            ),
            charts: charts,
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