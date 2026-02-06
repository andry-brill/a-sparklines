
part of 'main.dart';


List<ExampleChart> lineCharts() {
  return [
    ExampleChart(
      title: 'Simple line',
      plot: (options, charts) => SparklinesChart(
        width: options.width,
        height: options.height,
        charts: charts,
        animate: options.animation,
        crop: options.crop,
      ),
      initialCharts: [
        LineData(
          points: List.generate(
            20,
                (i) => DataPoint(
              x: i / 19,
              y: 0.5 + 0.3 * (i % 3 - 1),
            ),
          ),
          color: Colors.blue,
          width: 0.05,
        ),
      ],
      toggleCharts: [
        LineData(
          points: List.generate(
            20,
                (i) => DataPoint(
              x: i / 19,
              y: 0.3 + 0.4 * ((i * 1.5) % 3 - 1),
            ),
          ),
          color: Colors.red,
          width: 0.07,
        ),
      ],
    ),
    ExampleChart(
      title: 'Multiple lines',
      plot: (options, charts) => SparklinesChart(
        width: options.width,
        height: options.height,
        charts: charts,
        animate: options.animation,
        crop: options.crop,
      ),
      initialCharts: [
        LineData(
          points: List.generate(
            15,
                (i) => DataPoint(x: i / 14, y: 0.2 + (i % 4) * 0.2),
          ),
          color: Colors.blue,
          width: 0.03,
        ),
        LineData(
          points: List.generate(
            15,
                (i) => DataPoint(x: i / 14, y: 0.3 + (i % 3) * 0.15),
          ),
          color: Colors.green,
          width: 0.05,
        ),
      ],
      toggleCharts: [
        LineData(
          points: List.generate(
            15,
                (i) => DataPoint(x: i / 14, y: 0.4 + (i % 5) * 0.1),
          ),
          color: Colors.purple,
          width: 0.02,
        ),
        LineData(
          points: List.generate(
            15,
                (i) => DataPoint(x: i / 14, y: 0.1 + (i % 2) * 0.2),
          ),
          color: Colors.orange,
          width: 0.07,
        ),
      ],
    ),
  ];
}
