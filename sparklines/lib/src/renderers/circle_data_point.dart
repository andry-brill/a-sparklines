import 'dart:ui';

import 'package:sparklines/src/data/data_point.dart';
import 'package:sparklines/src/interfaces.dart';
import 'package:sparklines/src/renderers/data_point_renderer.dart';


/// Circle style for data points
class CircleDataPointStyle implements IDataPointStyle {

  static IDataPointRenderer defaultRenderer = CircleDataPointRenderer();

  final double radius;
  final Color color;

  const CircleDataPointStyle({
    required this.radius,
    required this.color,
  });

  @override
  IDataPointStyle lerpTo(IDataPointStyle next, double t) {
    if (next is! CircleDataPointStyle) return next;

    return CircleDataPointStyle(
      radius: lerpDouble(radius, next.radius, t) ?? next.radius,
      color: Color.lerp(color, next.color, t) ?? next.color,
    );
  }

  @override
  IDataPointRenderer get renderer => defaultRenderer;

}

class CircleDataPointRenderer extends ADataPointRenderer<CircleDataPointStyle> {

  @override
  void renderStyle(Paint paint, ChartRenderContext context, CircleDataPointStyle style, DataPoint dataPoint) {

    paint.style = PaintingStyle.fill;
    paint.color = style.color;
    paint.shader = null;

    final radius = context.toScreenLength(style.radius);
    context.drawCircle(dataPoint, radius, paint);
  }

}
