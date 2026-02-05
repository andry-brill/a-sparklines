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
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Sparklines Examples'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Line Chart',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 200,
              child: SparklinesChart(
                charts: [
                  LineData(
                    points: List.generate(
                      20,
                      (i) => DataPoint(
                        x: i / 19,
                        y: 0.5 + 0.3 * (i % 3 - 1),
                      ),
                    ),
                    color: Colors.blue,
                    width: 2.0,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Bar Chart',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 200,
              child: SparklinesChart(
                charts: [
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
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Pie Chart',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 200,
              child: SparklinesChart(
                charts: [
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}
