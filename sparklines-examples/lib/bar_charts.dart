
part of 'main.dart';

List<ExampleChart> barCharts() {
  return [
    ExampleChart(
      title: 'Simple bar',
      initialCharts: [
        BarData(
          bars: List.generate(
            10,
                (i) => DataPoint(
              x: i / 9,
              y: 0.2 + (i % 5) * 0.15,
            ),
          ),
          width: 0.08,
          color: Colors.green,
        ),
      ],
      toggleCharts: [
        BarData(
          bars: List.generate(
            10,
                (i) => DataPoint(
              x: i / 9,
              y: 0.1 + (i % 7) * 0.12,
            ),
          ),
          width: 0.08,
          color: Colors.blue,
        ),
      ],
    ),
    ExampleChart(
      title: 'Stacked bars',
      initialCharts: [
        BarData(
          bars: List.generate(
            8,
                (i) => DataPoint(x: i / 7, y: 0.2 + (i % 3) * 0.1),
          ),
          width: 0.1,
          color: Colors.blue,
          stacked: true,
        ),
        BarData(
          bars: List.generate(
            8,
                (i) => DataPoint(x: i / 7, y: 0.15 + (i % 2) * 0.1),
          ),
          width: 0.1,
          color: Colors.orange,
          stacked: true,
        ),
      ],
      toggleCharts: [
        BarData(
          bars: List.generate(
            8,
                (i) => DataPoint(x: i / 7, y: 0.3 + (i % 4) * 0.08),
          ),
          width: 0.1,
          color: Colors.purple,
          stacked: true,
        ),
        BarData(
          bars: List.generate(
            8,
                (i) => DataPoint(x: i / 7, y: 0.1 + (i % 3) * 0.12),
          ),
          width: 0.1,
          color: Colors.teal,
          stacked: true,
        ),
      ],
    ),
  ];
}
