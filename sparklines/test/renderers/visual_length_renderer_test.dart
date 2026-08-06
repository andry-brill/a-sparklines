import 'dart:math';
import 'dart:ui';

import 'package:any_sparklines/any_sparklines.dart';
import 'package:any_sparklines/data/layout_data.dart';
import 'package:any_sparklines/renderers/bar_chart_renderer.dart';
import 'package:any_sparklines/renderers/between_line_renderer.dart';
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

class _RecordingDataPointRenderer implements IDataPointRenderer {
  int calls = 0;

  @override
  void render(
    Canvas canvas,
    ChartTransform transform,
    Paint paint,
    IDataPointStyle style,
    Object dataPoint,
  ) {
    calls++;
  }
}

class _RecordingDataPointStyle
    extends ADataPointPlainData<_RecordingDataPointStyle>
    implements IDataPointStyle {
  final _RecordingDataPointRenderer recordingRenderer;

  _RecordingDataPointStyle(this.recordingRenderer);

  @override
  IDataPointRenderer get renderer => recordingRenderer;
}

class _RecordingLineTypeRenderer implements ILineTypeRenderer {
  int pathCalls = 0;
  int renderCalls = 0;

  @override
  Path toPath(
    ILineTypeData lineType,
    List<DataPoint> points, {
    bool reverse = false,
    Path? path,
  }) {
    pathCalls++;
    return path ?? Path();
  }

  @override
  void render(
    Canvas canvas,
    ChartTransform transform,
    ILineChartData lineData,
  ) {
    renderCalls++;
  }
}

class _RecordingLineTypeData implements ILineTypeData {
  final _RecordingLineTypeRenderer recordingRenderer;
  @override
  final bool drawLine;
  @override
  final int minPoints;

  _RecordingLineTypeData(
    this.recordingRenderer, {
    this.drawLine = true,
    this.minPoints = 2,
  });

  @override
  bool get isStrokeCapRound => false;

  @override
  bool get isStrokeJoinRound => false;

  @override
  ILineTypeRenderer get renderer => recordingRenderer;
}

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

  test('scatter skips line and area rendering while drawing every point', () {
    final pointRenderer = _RecordingDataPointRenderer();
    final lineRenderer = _RecordingLineTypeRenderer();
    final data = LineData.scatter(
      points: const [
        DataPoint(x: -0.5, y: -0.5, dy: 0),
        DataPoint(x: 0.5, y: 0.5, dy: 0),
      ],
      pointStyle: _RecordingDataPointStyle(pointRenderer),
    ).copyWith(
      areaColor: Colors.red,
      lineType: _RecordingLineTypeData(
        lineRenderer,
        drawLine: false,
        minPoints: 1,
      ),
    );

    LineChartRenderer().renderData(_canvas(), _transform(), data);

    expect(pointRenderer.calls, equals(2));
    expect(lineRenderer.pathCalls, equals(0));
    expect(lineRenderer.renderCalls, equals(0));
  });

  test('empty scatter renders no points', () {
    final pointRenderer = _RecordingDataPointRenderer();
    final data = LineData.scatter(
      points: const [],
      pointStyle: _RecordingDataPointStyle(pointRenderer),
    );

    LineChartRenderer().renderData(_canvas(), _transform(), data);

    expect(pointRenderer.calls, equals(0));
  });

  test('single-point scatter renders its marker', () {
    final pointRenderer = _RecordingDataPointRenderer();
    final data = LineData.scatter(
      points: const [DataPoint(x: 0, y: 0.5, dy: 0)],
      pointStyle: _RecordingDataPointStyle(pointRenderer),
    );

    LineChartRenderer().renderData(_canvas(), _transform(), data);

    expect(pointRenderer.calls, equals(1));
  });

  test('regular multi-point line retains line and marker rendering', () {
    final pointRenderer = _RecordingDataPointRenderer();
    final lineRenderer = _RecordingLineTypeRenderer();
    final data = LineData(
      line: const [
        DataPoint(x: -0.5, dy: -0.5),
        DataPoint(x: 0.5, dy: 0.5),
      ],
      pointStyle: _RecordingDataPointStyle(pointRenderer),
      lineType: _RecordingLineTypeData(lineRenderer),
    );

    LineChartRenderer().renderData(_canvas(), _transform(), data);

    expect(pointRenderer.calls, equals(2));
    expect(lineRenderer.renderCalls, equals(1));
  });

  test('single-point regular line renders its marker without a line', () {
    final pointRenderer = _RecordingDataPointRenderer();
    final lineRenderer = _RecordingLineTypeRenderer();
    final data = LineData(
      line: const [DataPoint(x: 0, dy: 0.5)],
      pointStyle: _RecordingDataPointStyle(pointRenderer),
      lineType: _RecordingLineTypeData(lineRenderer),
    );

    LineChartRenderer().renderData(_canvas(), _transform(), data);

    expect(pointRenderer.calls, equals(1));
    expect(lineRenderer.pathCalls, equals(0));
    expect(lineRenderer.renderCalls, equals(0));
  });

  test('line type minimum points suppresses geometry but not markers', () {
    final pointRenderer = _RecordingDataPointRenderer();
    final lineRenderer = _RecordingLineTypeRenderer();
    final data = LineData(
      line: const [
        DataPoint(x: -0.5, dy: -0.5),
        DataPoint(x: 0.5, dy: 0.5),
      ],
      pointStyle: _RecordingDataPointStyle(pointRenderer),
      lineType: _RecordingLineTypeData(lineRenderer, minPoints: 3),
    );

    LineChartRenderer().renderData(_canvas(), _transform(), data);

    expect(pointRenderer.calls, equals(2));
    expect(lineRenderer.pathCalls, equals(0));
    expect(lineRenderer.renderCalls, equals(0));
  });

  test('between-line fill skips line types that do not draw geometry', () {
    final fromRenderer = _RecordingLineTypeRenderer();
    final toRenderer = _RecordingLineTypeRenderer();
    final data = BetweenLineData(
      from: LineData(
        line: const [
          DataPoint(x: -0.5, dy: -0.5),
          DataPoint(x: 0.5, dy: 0.5),
        ],
        lineType: _RecordingLineTypeData(fromRenderer, drawLine: false),
      ),
      to: LineData(
        line: const [
          DataPoint(x: -0.5, dy: 0),
          DataPoint(x: 0.5, dy: 1),
        ],
        lineType: _RecordingLineTypeData(toRenderer),
      ),
    );

    BetweenLineRenderer().renderData(_canvas(), _transform(), data);

    expect(fromRenderer.pathCalls, equals(0));
    expect(toRenderer.pathCalls, equals(0));
  });

  test('between-line fill honors each line type minimum points', () {
    final fromRenderer = _RecordingLineTypeRenderer();
    final toRenderer = _RecordingLineTypeRenderer();
    final data = BetweenLineData(
      from: LineData(
        line: const [
          DataPoint(x: -0.5, dy: -0.5),
          DataPoint(x: 0.5, dy: 0.5),
        ],
        lineType: _RecordingLineTypeData(fromRenderer, minPoints: 3),
      ),
      to: LineData(
        line: const [
          DataPoint(x: -0.5, dy: 0),
          DataPoint(x: 0.5, dy: 1),
        ],
        lineType: _RecordingLineTypeData(toRenderer),
      ),
    );

    BetweenLineRenderer().renderData(_canvas(), _transform(), data);

    expect(fromRenderer.pathCalls, equals(0));
    expect(toRenderer.pathCalls, equals(0));
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
