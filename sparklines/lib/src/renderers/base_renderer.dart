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
      final center = Offset(transformer.width / 2, transformer.height / 2);
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

  /// Transform BorderRadius values based on relativeDimensions
  BorderRadius transformBorderRadius(
      BorderRadius borderRadius,
      CoordinateTransformer transformer,
      ) {
    return BorderRadius.only(
      topLeft: Radius.elliptical(
        transformer.transformDimension(borderRadius.topLeft.x),
        transformer.transformDimension(borderRadius.topLeft.y),
      ),
      topRight: Radius.elliptical(
        transformer.transformDimension(borderRadius.topRight.x),
        transformer.transformDimension(borderRadius.topRight.y),
      ),
      bottomLeft: Radius.elliptical(
        transformer.transformDimension(borderRadius.bottomLeft.x),
        transformer.transformDimension(borderRadius.bottomLeft.y),
      ),
      bottomRight: Radius.elliptical(
        transformer.transformDimension(borderRadius.bottomRight.x),
        transformer.transformDimension(borderRadius.bottomRight.y),
      ),
    );
  }
}
