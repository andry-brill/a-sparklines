
part of 'main.dart';

List<ExampleChart> pieCharts() {
  return [
    ExampleChart(
      title: 'Simple pie',
      initialCharts: [
        PieData(
          pies: [
            DataPoint(x: 0, y: 30),
            DataPoint(x: 0, y: 20),
            DataPoint(x: 0, y: 25),
            DataPoint(x: 0, y: 25),
          ],
          color: Colors.purple,
        ),
      ],
      toggleCharts: [
        PieData(
          pies: [
            DataPoint(x: 0, y: 40),
            DataPoint(x: 0, y: 15),
            DataPoint(x: 0, y: 20),
            DataPoint(x: 0, y: 25),
          ],
          color: Colors.purple,
        ),
      ],
    ),
    ExampleChart(
      title: 'Pie with spacing',
      initialCharts: [
        PieData(
          pies: [
            DataPoint(x: 0, y: 25),
            DataPoint(x: 0, y: 20),
            DataPoint(x: 0, y: 30),
            DataPoint(x: 0, y: 25),
          ],
          color: Colors.blue,
          space: 2.0,
        ),
      ],
      toggleCharts: [
        PieData(
          pies: [
            DataPoint(x: 0, y: 35),
            DataPoint(x: 0, y: 15),
            DataPoint(x: 0, y: 25),
            DataPoint(x: 0, y: 25),
          ],
          color: Colors.blue,
          space: 2.0,
        ),
      ],
    ),
  ];
}
