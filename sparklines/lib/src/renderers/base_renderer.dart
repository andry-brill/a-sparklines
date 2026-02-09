import 'package:flutter/material.dart';
import '../coordinate_transformer.dart';
import '../interfaces.dart';

abstract class BaseRenderer<DT extends ISparklinesData> implements IChartRenderer {

  @override
  void render(
    Canvas canvas,
    CoordinateTransformer transformer,
    ISparklinesData data,
  ) {
    if (!data.visible) return;

    canvas.save();

    if (transformer.crop) {
      canvas.clipRect(transformer.bounds);
    }

    canvas.translate(
        transformer.transformDx(data.origin.dx),
        transformer.transformDy(data.origin.dy)
    );

    if (data.rotation != 0.0) {
      final center = transformer.center;
      canvas.translate(center.dx, center.dy);
      canvas.rotate(data.rotation);
      canvas.translate(-center.dx, -center.dy);
    }

    renderData(canvas, transformer, data as DT);

    canvas.restore();
  }

  void renderData(Canvas canvas, CoordinateTransformer transformer, DT data);

  RRect? roundedRect(CoordinateTransformer transformer, IChartBorder border, Rect rect) {

    if (border.borderRadius == null || border.borderRadius == 0.0) {
      return null;
    }

    final r = transformer.transformDimension(border.borderRadius!);
    return RRect.fromRectXY(rect, r, r);
  }

}
