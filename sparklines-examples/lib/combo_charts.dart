
part of 'main.dart';

List<ExampleChart> comboCharts() {
  return [
    ExampleChart(
      title: 'Line and bar',
      initialCharts: [
        BarData(
          layout: const RelativeLayout.normalized(),
          bars: List.generate(
            10,
            (i) => DataPoint(x: i / 9, y: 0, dy: 0.2 + (i % 4) * 0.1),
          ),
          thickness: ThicknessData(size: Dx(0.08), color: Colors.green.withValues(alpha: 0.5)),
        ),
        LineData(
          layout: const RelativeLayout.normalized(),
          line: List.generate(
            10,
            (i) => DataPoint(x: i / 9, y: 0, dy: 0.3 + (i % 3) * 0.15),
          ),
          thickness: ThicknessData(size: Px(2.0), color: Colors.blue),
          pointStyle: const CircleDataPointStyle(radius: Px(2), color: Colors.blue),
        ),
      ],
      toggleCharts: [
        BarData(
          layout: const RelativeLayout.normalized(),
          bars: List.generate(
            10,
            (i) => DataPoint(x: i / 9, y: 0, dy: 0.15 + (i % 5) * 0.12),
          ),
          thickness: ThicknessData(size: Dx(0.08), color: Colors.orange.withValues(alpha: 0.5)),
        ),
        LineData(
          layout: const RelativeLayout.normalized(),
          line: List.generate(
            10,
            (i) => DataPoint(x: i / 9, y: 0, dy: 0.4 + (i % 4) * 0.1),
          ),
          thickness: ThicknessData(size: Px(2.0), color: Colors.red),
          pointStyle: const CircleDataPointStyle(radius: Px(2), color: Colors.red),
        ),
      ],
    ),
  ];
}
