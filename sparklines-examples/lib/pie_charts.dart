
part of 'main.dart';


List<ExampleChart> pieCharts() {
  return [
    ExampleChart(
      title: 'Single pie',
      subtitle: 'Single pie on absolute layout',
      initialCharts: [
        PieData(
          debug: '>>>ABS<<< ',
          points: [DataPoint(x: 72.0, y: pi/4.0, dy: pi/4.0)],
          thickness: ThicknessData(size: 18, color: Colors.blue),
        ),
      ],
      toggleCharts: [
        PieData(
          points: [DataPoint(x: 75.0, y: -pi/4.0, dy: pi/8.0)],
          thickness: ThicknessData(size: 30, color: Colors.deepOrange),
        ),
      ],
    ),
    ExampleChart(
      title: 'Single pie',
      subtitle: 'Single pie on absolute layout',
      initialCharts: [
        PieData(
          debug: '>>>REL<<< ',
          layout: const RelativeLayout.full(),
          points: [DataPoint(x: 72.0, y: pi/4.0, dy: pi/4.0)],
          thickness: ThicknessData(size: 30, color: Colors.blue),
        ),
      ],
      toggleCharts: [
        PieData(
          layout: const RelativeLayout.full(),
          points: [DataPoint(x: 75.0, y: -pi/4.0, dy: pi/8.0)],
          thickness: ThicknessData(size: 30, color: Colors.deepOrange),
        ),
      ],
    ),
  ];
}
