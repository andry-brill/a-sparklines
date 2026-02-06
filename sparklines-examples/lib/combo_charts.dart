
part of 'main.dart';

List<ExampleChart> comboCharts() {
  return [
    ExampleChart(
      title: 'Line and bar',
      plot: (options, charts) => SparklinesChart(
        width: options.width,
        height: options.height,
        charts: charts,
        animate: options.animation,
        crop: options.crop,
      ),
      initialCharts: [
        BarData(
          bars: List.generate(
            10,
                (i) => DataPoint(x: i / 9, y: 0.2 + (i % 4) * 0.1),
          ),
          width: 0.08,
          color: Colors.green.withValues(alpha: 0.5),
        ),
        LineData(
          points: List.generate(
            10,
                (i) => DataPoint(x: i / 9, y: 0.3 + (i % 3) * 0.15),
          ),
          color: Colors.blue,
          width: 2.0,
        ),
      ],
      toggleCharts: [
        BarData(
          bars: List.generate(
            10,
                (i) => DataPoint(x: i / 9, y: 0.15 + (i % 5) * 0.12),
          ),
          width: 0.08,
          color: Colors.orange.withValues(alpha: 0.5),
        ),
        LineData(
          points: List.generate(
            10,
                (i) => DataPoint(x: i / 9, y: 0.4 + (i % 4) * 0.1),
          ),
          color: Colors.red,
          width: 2.0,
        ),
      ],
    ),
  ];
}
