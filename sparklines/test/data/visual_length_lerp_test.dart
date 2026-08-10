import 'package:any_sparklines/any_sparklines.dart';
import 'package:any_sparklines/data/layout_data.dart';
import 'package:flutter/material.dart';
import 'package:test/test.dart';

ChartTransform _transform() {
  const dimensions = LayoutData(
    minX: 0,
    maxX: 1,
    minY: 0,
    maxY: 1,
    width: 200,
    height: 100,
  );
  const layout = RelativeLayout.normalized();
  return ChartTransform(
    dimensions: dimensions,
    pathTransform: layout.transform(dimensions),
  );
}

void main() {
  test('ThicknessData lerps different units after resolution', () {
    const from = ThicknessData(size: Px(2));
    const to = ThicknessData(size: Vw(10));

    final middle = from.lerpTo(to, 0.5);

    expect(_transform().length(middle.size), 11);
  });

  test('ThicknessOverride lerps nullable sizes through zero', () {
    const from = ThicknessOverride();
    const to = ThicknessOverride(size: Dy(0.1));

    final middle = from.lerp(to, 0.5);

    expect(_transform().length(middle.size!), 5);
  });

  test('CircleDataPointStyle defers radius interpolation and exposes its extent', () {
    const from = CircleDataPointStyle(radius: Px(2), color: Colors.black);
    const to = CircleDataPointStyle(radius: Vh(10), color: Colors.white);

    final middle = from.lerp(to, 0.5);

    expect(from.extent, const ChartInsets.all(Px(2)));
    expect(_transform().length(middle.radius), 6);
  });

  test('chart border radius supports cross-unit interpolation', () {
    final from = BarData(
      bars: const [DataPoint(x: 0, dy: 1)],
      borderRadius: const Px(2),
    );
    final to = BarData(
      bars: const [DataPoint(x: 0, dy: 1)],
      borderRadius: const Vh(10),
    );

    final middle = from.lerpTo(to, 0.5) as BarData;

    expect(_transform().length(middle.borderRadius!), 6);
  });

  test('nullable border radius animates from zero', () {
    const from = DataPointBorder();
    const to = DataPointBorder(borderRadius: Px(10));

    final middle = from.lerp(to, 0.5);

    expect(_transform().length(middle.borderRadius!), 5);
  });
}
