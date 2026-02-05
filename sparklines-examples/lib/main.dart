import 'package:flutter/material.dart';
import 'package:sparklines/sparklines.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sparklines Examples',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueGrey),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Sparklines Examples'),
    );
  }
}

class CommonOptions {
  final double? width;
  final double? height;
  final bool animation;
  final bool crop;

  const CommonOptions({
    this.width,
    this.height,
    this.animation = true,
    this.crop = false,
  });

  CommonOptions copyWith({
    double? width,
    double? height,
    bool? animation,
    bool? crop,
  }) {
    return CommonOptions(
      width: width ?? this.width,
      height: height ?? this.height,
      animation: animation ?? this.animation,
      crop: crop ?? this.crop,
    );
  }
}

class ExampleChart {
  final String title;
  final Widget Function(CommonOptions options, List<ISparklinesData> charts) plot;
  final List<ISparklinesData> initialCharts;
  final List<ISparklinesData> toggleCharts;

  const ExampleChart({
    required this.title,
    required this.plot,
    required this.initialCharts,
    required this.toggleCharts,
  });
}

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

List<ExampleChart> barCharts() {
  return [
    ExampleChart(
      title: 'Simple bar',
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

List<ExampleChart> pieCharts() {
  return [
    ExampleChart(
      title: 'Simple pie',
      plot: (options, charts) => SparklinesChart(
        width: options.width,
        height: options.height,
        charts: charts,
        animate: options.animation,
        crop: options.crop,
      ),
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
      plot: (options, charts) => SparklinesChart(
        width: options.width,
        height: options.height,
        charts: charts,
        animate: options.animation,
        crop: options.crop,
      ),
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

List<ExampleChart> multiCharts() {
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

final examples = {
  'Line charts': lineCharts(),
  'Bar charts': barCharts(),
  'Pie charts': pieCharts(),
  'Multi charts': multiCharts(),
};

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  static const w = 150.0;
  static const h = 150.0;
  double _customWidth = w;
  double _customHeight = h;
  bool _animation = true;
  bool _crop = false;
  final Map<String, Map<String, bool>> _chartStates = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: examples.length,
      vsync: this,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  bool _isToggled(String category, String title) {
    return _chartStates[category]?[title] ?? false;
  }

  void _toggleChart(String category, String title) {
    setState(() {
      _chartStates.putIfAbsent(category, () => {});
      _chartStates[category]![title] = !_isToggled(category, title);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        shadowColor: Colors.transparent,
        title: Text(widget.title),
        elevation: 0,
        forceMaterialTransparency: true,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        bottom: TabBar(
          dividerColor: Colors.transparent,
          dividerHeight: 0,
          controller: _tabController,
          tabs: examples.keys.map((key) => Tab(text: key)).toList(),
        ),
      ),
      body: Column(
        children: [
          // Controls
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Width: ${_customWidth.toInt()}'),
                          Slider(
                            value: _customWidth,
                            min: 0,
                            max: 300,
                            divisions: 30,
                            onChanged: (value) {
                              setState(() {
                                _customWidth = value;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Row(
                        children: [
                          Text('Animation:'),
                          const SizedBox(width: 8),
                          Switch(
                            value: _animation,
                            onChanged: (value) {
                              setState(() {
                                _animation = value;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Height: ${_customHeight.toInt()}'),
                          Slider(
                            value: _customHeight,
                            min: 0,
                            max: 300,
                            divisions: 30,
                            onChanged: (value) {
                              setState(() {
                                _customHeight = value;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Row(
                        children: [
                          Text('Crop:'),
                          const SizedBox(width: 8),
                          Switch(
                            value: _crop,
                            onChanged: (value) {
                              setState(() {
                                _crop = value;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: examples.entries.map((entry) {
                return _buildCategoryView(entry.key, entry.value);
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryView(String category, List<ExampleChart> charts) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: charts.map((chart) => _buildChartExample(category, chart)).toList(),
      ),
    );
  }

  Widget _buildChartExample(String category, ExampleChart chart) {
    final isToggled = _isToggled(category, chart.title);
    final currentCharts = isToggled ? chart.toggleCharts : chart.initialCharts;

    final baseOptions = CommonOptions(
      animation: _animation,
      crop: _crop,
    );

    final sizeVariants = [
      {'width': _customWidth, 'height': _customHeight},
      {'width': w, 'height': h / 2.0},
      {'width': w / 2.0, 'height': h},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          chart.title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 24,
          runSpacing: 24,
          children: sizeVariants.map((variant) {
            final options = baseOptions.copyWith(
              width: variant['width'] as double,
              height: variant['height'] as double,
            );

            return GestureDetector(
              onTap: () => _toggleChart(category, chart.title),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade200),
                  borderRadius: BorderRadius.circular(3),
                ),
                child: Container(
                  width: variant['width'] as double,
                  height: variant['height'] as double,
                  child: chart.plot(options, currentCharts),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}
