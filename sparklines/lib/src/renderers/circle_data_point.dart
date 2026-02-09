
import 'dart:ui';

import 'package:sparklines/src/coordinate_transformer.dart';
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
  void renderStyle(Canvas canvas, Paint paint, CoordinateTransformer transformer, CircleDataPointStyle style, DataPoint dataPoint) {

    paint.style = PaintingStyle.fill;
    paint.color = style.color;
    paint.shader = null;

    final screenPoint = transformer.transformPoint(dataPoint);
    final radius = transformer.transformDimension(style.radius);
    canvas.drawCircle(screenPoint, radius, paint);

  }

}
