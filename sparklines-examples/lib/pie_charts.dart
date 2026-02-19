
part of 'main.dart';


List<ExampleChart> pieCharts() {
  return [
    ExampleChart(
      title: 'Absolute layout',
      subtitle: 'Single pie on absolute layout',
      initialCharts: [
        PieData(
          points: [DataPoint(x: 72.0, y: pi/4.0, dy: pi/2.0)],
          thickness: ThicknessData(size: 18, color: Colors.blue),
        ),
      ],
      toggleCharts: [
        PieData(
          points: [DataPoint(x: 72.0, y: 0, dy: pi/4.0)],
          thickness: ThicknessData(size: 30, color: Colors.deepOrange),
        ),
      ],
    ),
    ExampleChart(
      title: 'Relative layout',
      subtitle: 'Single pie on relative layout',
      initialCharts: [
        PieData(
          layout: const RelativeLayout.full(),
          points: [DataPoint(x: 72.0, y: pi/4.0, dy: pi/2.0)],
          thickness: ThicknessData(size: 30, color: Colors.blue),
        ),
      ],
      toggleCharts: [
        PieData(
          layout: const RelativeLayout.full(),
          points: [DataPoint(x: 75.0, y: 0, dy: pi/4.0)],
          thickness: ThicknessData(size: 30, color: Colors.deepOrange),
        ),
      ],
    ),
    ExampleChart(
      title: 'Relative fixed layout',
      initialCharts: [
        PieData(
          layout: const RelativeLayout(minX: -gridWidth, maxX: gridWidth, minY: -gridHeight, maxY: gridHeight),
          points: [
            DataPoint(x: 100.0, y: 0, dy: pi/6.0),
            DataPoint(x: 100.0, y: pi/3.0, dy: pi/6.0),
            DataPoint(x: 100.0, y: 2 * pi/3.0, dy: pi/3.0)
          ],
          borderRadius: 8.0,
          pointStyle: CircleDataPointStyle(radius: 4, color: Colors.white),
          thickness: ThicknessData(size: 40, color: Colors.blue),
        ),
        PieData(
          layout: const RelativeLayout(minX: -gridWidth, maxX: gridWidth, minY: -gridHeight, maxY: gridHeight),
          points: [
            DataPoint(x: 50.0, y: 0, dy: pi/3.0),
            DataPoint(x: 50.0, y: 1.5 * pi/3.0, dy: pi/3.0)
          ],
          borderRadius: 5.0,
          thickness: ThicknessData(size: 10, color: Colors.pink),
        ),
      ],
      toggleCharts: [
        PieData(
          layout: const RelativeLayout(minX: -gridWidth, maxX: gridWidth, minY: -gridHeight, maxY: gridHeight),
          points: [
            DataPoint(x: 100.0, y: 0, dy: pi/3.0),
            DataPoint(x: 100.0, y: 2 * pi/3.0, dy: pi/3.0),
            DataPoint(x: 100.0, y: 4 * pi/3.0, dy: pi/3.0)
          ],
          borderRadius: 8.0,
          pointStyle: CircleDataPointStyle(radius: 4, color: Colors.white),
          thickness: ThicknessData(size: 40, color: Colors.blue),
        ),
        PieData(
          layout: const RelativeLayout(minX: -gridWidth, maxX: gridWidth, minY: -gridHeight, maxY: gridHeight),
          points: [
            DataPoint(x: 50.0, y: 0, dy: pi),
            DataPoint(x: 50.0, y: pi + pi/6.0, dy: pi - pi/3.0)
          ],
          borderRadius: 5.0,
          thickness: ThicknessData(size: 10, color: Colors.pink),
        ),
      ],
    ),
    ExampleChart(
      title: 'Dynamic thickness',
      initialCharts: [
        PieData(
          layout: const RelativeLayout(minX: -gridWidth, maxX: gridWidth, minY: -gridHeight, maxY: gridHeight),
          points: [
            DataPoint(x: 100.0, y: 0, dy: pi/6.0),
            DataPoint(x: 100.0, y: pi/6.0, dy: pi/6.0, thickness: ThicknessOverride(size: 30, align: ThicknessData.alignOutside, color: Colors.blue.shade600)),
            DataPoint(x: 100.0, y: pi/3.0, dy: pi/6.0, thickness: ThicknessOverride(size: 40, align: ThicknessData.alignOutside, color: Colors.blue.shade900))
          ],
          borderRadius: 4.0,
          space: 10,
          thickness: ThicknessData(size: 20, color: Colors.blue.shade300, align: ThicknessData.alignOutside),
        ),
      ],
      toggleCharts: [
        PieData(
          layout: const RelativeLayout(minX: -gridWidth, maxX: gridWidth, minY: -gridHeight, maxY: gridHeight),
          points: [
            DataPoint(x: 100.0, y: 0, dy: pi/3.0),
            DataPoint(x: 100.0, y: pi/3.0, dy: pi/3.0, thickness: ThicknessOverride(size: 30, align: ThicknessData.alignOutside, color: Colors.blue.shade600)),
            DataPoint(x: 100.0, y: 2 * pi/3.0, dy: pi/3.0, thickness: ThicknessOverride(size: 40, align: ThicknessData.alignOutside, color: Colors.blue.shade900))
          ],
          borderRadius: 4.0,
          space: 10,
          thickness: ThicknessData(size: 20, color: Colors.blue.shade300, align: ThicknessData.alignOutside),
        ),
      ],
    ),
  ];
}
