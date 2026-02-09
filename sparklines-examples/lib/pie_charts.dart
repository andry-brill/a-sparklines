
part of 'main.dart';


List<ExampleChart> pieCharts() {
  return [
    ExampleChart(
      title: 'Single pie',
      initialCharts: [
        PieData(
          points: [DataPoint(x: 100.0, y: 0.0, dy: 50.0)],
          thickness: ThicknessData(size: pi/4.0, color: Colors.blue),
        ),
      ],
      toggleCharts: [
        PieData(
          points: [DataPoint(x: 0, y: 100.0, dy: 50.0)],
          thickness: ThicknessData(size: pi/4.0, color: Colors.blue),
        ),
      ],
    ),
  ];
}
