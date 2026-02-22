import 'dart:math';

import 'package:flutter/material.dart';
import 'package:sparklines/sparklines.dart';

final pie1 = PieData(
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
  space: 10,
  thickness: ThicknessData(
    size: 20,
    color: Colors.blue.shade300,
    align: ThicknessData.alignOutside,
  ),
);


final pie2 = PieData(
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
  space: 10,
  thickness: ThicknessData(
    size: 20,
    color: Colors.blue.shade300,
    align: ThicknessData.alignOutside,
  ),
);

final line1 = LineData(
    // origin: const Offset(0, -140),
    lineType: CurvedLineData(isStrokeCapRound: true, isStrokeJoinRound: true, smoothness: 1.0),
    thickness: ThicknessData(size: 8, color: Colors.blue),
    areaGradient: LinearGradient(colors: [Colors.lightBlue, Colors.lightBlue.withValues(alpha: 0)], begin: AlignmentGeometry.topCenter, end: AlignmentGeometry.bottomCenter),
    points: [
  DataPoint(x: -140, dy: 120),
  DataPoint(x: -100, dy: 50),
  DataPoint(x: -40, dy: 80),
  DataPoint(x: -10, dy: 20),
]);

final line2 = LineData(
  // origin: const Offset(0, -140),
  lineType: CurvedLineData(isStrokeCapRound: true, isStrokeJoinRound: true, smoothness: 1.0),
  thickness: ThicknessData(size: 8, color: Colors.blue),
  areaGradient: LinearGradient(colors: [Colors.lightBlue, Colors.lightBlue.withValues(alpha: 0)], begin: AlignmentGeometry.topCenter, end: AlignmentGeometry.bottomCenter),
  points: [
    DataPoint(x: -140, dy: 20),
    DataPoint(x: -100, dy: 80),
    DataPoint(x: -40, dy: 50),
    DataPoint(x: -10, dy: 120),
]);

class _ExamplePageState extends State<_ExamplePage> {

  bool _toggled = false;

  static final _initialCharts = [
    pie1, line1
  ];

  static final _toggleCharts = [
    pie2, line2
  ];

  @override
  Widget build(BuildContext context) {

    final charts = _toggled ? _toggleCharts : _initialCharts;

    return Scaffold(
      body: GestureDetector(
        onTap: () => setState(() => _toggled = !_toggled),
        child: Container(
          padding: EdgeInsets.only(top: 30),
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