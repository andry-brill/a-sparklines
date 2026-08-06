import 'dart:math';
import 'dart:ui';

import 'package:any_sparklines/any_sparklines.dart';
import 'package:any_sparklines/data/layout_data.dart';
import 'package:any_sparklines/renderers/bar_chart_renderer.dart';
import 'package:any_sparklines/renderers/line_chart_renderer.dart';
import 'package:any_sparklines/renderers/pie_chart_renderer.dart';
import 'package:flutter/material.dart' show Colors;
import 'package:test/test.dart';

ChartTransform _transform() {
  const dimensions = LayoutData(
    minX: -1,
    maxX: 1,
    minY: -1,
    maxY: 1,
    width: 240,
    height: 120,
  );
  const layout = RelativeLayout.signed();
  return ChartTransform(
    dimensions: dimensions,
    pathTransform: layout.transform(dimensions),
  );
}

Canvas _canvas() => Canvas(PictureRecorder());

void main() {
  test('line and markers render with mixed length units', () {
    final data = LineData(
      line: const [DataPoint(x: -1, dy: -0.5), DataPoint(x: 1, dy: 0.5)],
      thickness: const ThicknessData(size: Px(2)),
      pointStyle: const CircleDataPointStyle(radius: Vh(2), color: Colors.blue),
    );

    expect(
      () => LineChartRenderer().renderData(_canvas(), _transform(), data),
      returnsNormally,
    );
  });

  test('bar, border, corner, and marker lengths render independently', () {
    final data = BarData(
      bars: const [DataPoint(x: 0, y: -1, dy: 1.5)],
      thickness: const ThicknessData(size: Dx(0.2), color: Colors.blue),
      border: const ThicknessData(size: Px(2), color: Colors.black),
      borderRadius: const Vh(2),
      pointStyle: const CircleDataPointStyle(radius: Px(3), color: Colors.red),
    );

    expect(
      () => BarChartRenderer().renderData(_canvas(), _transform(), data),
      returnsNormally,
    );
  });

  test('dynamic stepped line resolves visual lengths in screen space', () {
    final data = LineData(
      line: const [
        DataPoint(
          x: -1,
          dy: -0.5,
          data: {IThicknessOverride: ThicknessOverride(size: Vw(2))},
        ),
        DataPoint(
          x: 0,
          dy: 0.5,
          data: {IThicknessOverride: ThicknessOverride(size: Dy(0.2))},
        ),
        DataPoint(x: 1, dy: 0),
      ],
      thickness: const ThicknessData(size: Px(2)),
      lineType: const SteppedLineData.middle(
        isStrokeCapRound: true,
        isStrokeJoinRound: true,
      ),
    );

    expect(
      () => LineChartRenderer().renderData(_canvas(), _transform(), data),
      returnsNormally,
    );
  });

  test('pie visual lengths render on a non-square relative layout', () {
    final data = PieData(
      pies: const [DataPoint(x: 0.6, y: 0, dy: 1.5 * pi)],
      thickness: const ThicknessData(size: Dx(0.15), color: Colors.blue),
      border: const ThicknessData(size: Vh(1), color: Colors.black),
      borderRadius: const Px(3),
      pointStyle: const CircleDataPointStyle(radius: Vw(1), color: Colors.red),
    );

    expect(
      () => PieChartRenderer().renderData(_canvas(), _transform(), data),
      returnsNormally,
    );
  });
}
