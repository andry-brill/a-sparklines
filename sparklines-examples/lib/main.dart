import 'dart:math';

import 'package:flutter/material.dart';
import 'package:sparklines/sparklines.dart';

part 'line_charts.dart';
part 'bar_charts.dart';
part 'pie_charts.dart';
part 'combo_charts.dart';

void main() {
  runApp(const MyApp());
}

const gridWidth = 150.0;
const gridHeight = 150.0;

double xR(double value) => value / gridWidth;
double yR(double value) => value / gridHeight;
List<DataPoint> dpR(Iterable<DataPoint> point) => point.map((p) => DataPoint(x: xR(p.x), y: yR(p.y), dy: yR(p.dy), style: p.style)).toList();

double xI(int i) => (gridWidth / 10.0) * i;
double yI(int i) => (gridHeight / 10.0) * i;
DataPoint dpI(int xi, int yi, {double? size, Color? color}) => DataPoint.value(xI(xi), yI(yi),
    thickness: size != null || color != null ? ThicknessOverride(size: size, color: color) : null);

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

class ExampleChart<C extends ISparklinesData> {

  final String title;
  final String? subtitle;
  final List<C> initialCharts;
  final List<C> toggleCharts;

  ExampleChart({
    required this.title,
    this.subtitle,
    required List<C> initialCharts,
    required List<C> toggleCharts,
    C Function(C)? modifier
  }) :
    this.initialCharts = modifier == null ? initialCharts : initialCharts.map(modifier).toList(),
    this.toggleCharts = modifier == null ? toggleCharts : toggleCharts.map(modifier).toList();

  ExampleChart<C> modify({required String title,
    String? subtitle,
    required C Function(C) modifier
  }) => ExampleChart<C>(title: title, subtitle: subtitle, initialCharts: initialCharts, toggleCharts: toggleCharts, modifier: modifier);

  Widget plot(options, charts) => SparklinesChart(
    width: options.width,
    height: options.height,
    charts: charts,
    animate: options.animation,
    crop: options.crop,
  );
}


final examples = {
  'Line charts': lineCharts(),
  'Bar charts': barCharts(),
  'Pie charts': pieCharts(),
  'Combo charts': comboCharts(),
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
  double _customWidth = gridWidth;
  double _customHeight = gridHeight;
  bool _animation = true;
  bool _crop = true;
  final Map<String, Map<String, bool>> _chartStates = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      initialIndex: 2,
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
        crossAxisAlignment: CrossAxisAlignment.center,
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
      {'width': gridWidth, 'height': gridHeight / 2.0},
      {'width': gridWidth / 2.0, 'height': gridHeight},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        Text(chart.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        if (chart.subtitle != null) ConstrainedBox(constraints: BoxConstraints(maxWidth: gridWidth * 3), child: Text(chart.subtitle!, softWrap: true, style: const TextStyle(fontSize: 16))),
        const SizedBox(height: 16),
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
