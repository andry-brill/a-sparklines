
part of 'main.dart';

List<ExampleChart> pieCharts() {
  return [
    ExampleChart(
      title: 'Simple pie',
      initialCharts: [
        PieData(
          points: [
            DataPoint.value(0, 30),
            DataPoint.value(0, 20),
            DataPoint.value(0, 25),
            DataPoint.value(0, 25),
          ],
          thickness: ThicknessData(size: double.infinity, color: Colors.purple),
        ),
      ],
      toggleCharts: [
        PieData(
          points: [
            DataPoint.value(0, 40),
            DataPoint.value(0, 15),
            DataPoint.value(0, 20),
            DataPoint.value(0, 25),
          ],
          thickness: ThicknessData(size: double.infinity, color: Colors.purple),
        ),
      ],
    ),
    ExampleChart(
      title: 'Pie with spacing',
      initialCharts: [
        PieData(
          points: [
            DataPoint.value(0, 25),
            DataPoint.value(0, 20),
            DataPoint.value(0, 30),
            DataPoint.value(0, 25),
          ],
          thickness: ThicknessData(size: double.infinity, color: Colors.blue),
          space: 2.0,
        ),
      ],
      toggleCharts: [
        PieData(
          points: [
            DataPoint.value(0, 35),
            DataPoint.value(0, 15),
            DataPoint.value(0, 25),
            DataPoint.value(0, 25),
          ],
          thickness: ThicknessData(size: double.infinity, color: Colors.blue),
          space: 2.0,
        ),
      ],
    ),
  ];
}
