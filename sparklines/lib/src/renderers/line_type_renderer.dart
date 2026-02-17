
import 'package:flutter/material.dart';
import 'package:sparklines/src/data/data_point.dart';
import 'package:sparklines/src/interfaces.dart';

import '../data/line_data.dart';

/// Base renderer with shared moveToStart logic
abstract class BaseLineTypeRenderer<LD extends ILineTypeData> implements ILineTypeRenderer {

  const BaseLineTypeRenderer();

  @override
  Path toPath(ILineTypeData lineType, List<DataPoint> points, {bool useFy = true, bool reverse = false, Path? path}) {

    final pathOut = path ?? Path();
    if (points.isEmpty) return pathOut;

    moveToStart(pathOut, points, useFy, reverse);
    if (points.length == 1) return pathOut;

    return toLinePath(lineType as LD, pathOut, points, useFy: useFy, reverse: reverse);
  }

  Path toLinePath(LD lineType, Path path, List<DataPoint> points, {bool useFy = true, bool reverse = false});

  void moveToStart(Path path, List<DataPoint> points, bool useFy, bool reverse) {
    if (!reverse) {
      final first = points[0];
      path.moveTo(first.x, first.getYorFY(useFy));
    } else {
      final last = points.last;
      path.moveTo(last.x, last.getYorFY(useFy));
    }
  }

  bool _isSameStrokeSize(ThicknessData stroke, List<DataPoint> points) {
    final size = stroke.size;
    for (var point in points) {
      final override = point.thickness?.size;
      if (override != null && size != override) return false;
    }
    return true;
  }

  bool _isSameStrokePainter(ThicknessData stroke, List<DataPoint> points) {
    final painter = stroke.gradient ?? stroke.color;
    for (var point in points) {
      final override = point.thickness?.gradient ?? point.thickness?.color;
      if (override != null && painter != override) return false;
    }
    return true;
  }

  @override
  void render(ChartRenderContext context, LineData lineData) {

    final points = lineData.points;
    if (points.length < 2) return;

    final bool sameStroke = _isSameStrokeSize(lineData.thickness, points);
    final bool samePaint = _isSameStrokePainter(lineData.thickness, points);

    if (sameStroke && samePaint) {
      renderSimplePath(context, lineData);
    } else {
      renderComplexPath(context, lineData, !sameStroke, !samePaint);
    }
  }

  Paint buildPaint(ChartRenderContext context, LineData lineData, [ThicknessOverride? override]) {
    return Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = context.toScreenLength(override?.size ?? lineData.thickness.size)
      ..strokeCap = lineData.lineType.isStrokeCapRound ? StrokeCap.round : StrokeCap.butt
      ..strokeJoin = lineData.lineType.isStrokeJoinRound ? StrokeJoin.round : StrokeJoin.miter;
  }

  void paintThickness(Paint paint, Rect bounds, ThicknessData thickness, [ThicknessOverride? override]) {

    final gradient = override?.gradient ?? thickness.gradient;

    if (gradient != null) {
      paint.shader = gradient.createShader(bounds);
    } else {
      paint.shader = null;
      paint.color = override?.color ?? thickness.color;
    }
  }

  void renderSimplePath(ChartRenderContext context, LineData lineData) {

    final stroke = lineData.thickness;

    final path = toPath(lineData.lineType, lineData.points);
    final tPath = path.transform(context.pathTransform.storage);

    final paint = buildPaint(context, lineData);
    paintThickness(paint, tPath.getBounds(), stroke);
    context.canvas.drawPath(tPath, paint);
  }

  void renderComplexPath(ChartRenderContext context, LineData lineData, bool isDynamicStroke, bool isDynamicPaint);
}

/// Renders linear (straight line) connections between points
class LinearLineRenderer extends BaseLineTypeRenderer<LinearLineData> {

  const LinearLineRenderer();

  @override
  Path toLinePath(LinearLineData lineType, Path path, List<DataPoint> points, {bool useFy = true, bool reverse = false}) {

    if (reverse) {
      for (int i = points.length - 2; i >= 0; i--) {
        final point = points[i];
        path.lineTo(point.x, point.getYorFY(useFy));
      }
    } else {
      for (int i = 1; i < points.length; i++) {
        final point = points[i];
        path.lineTo(point.x, point.getYorFY(useFy));
      }
    }

    return path;
  }

  @override
  void renderComplexPath(ChartRenderContext context, LineData lineData, bool isDynamicStroke, bool isDynamicPaint) {
  }
}

/// Renders curved (smooth) line connections between points
class CurvedLineRenderer extends BaseLineTypeRenderer<CurvedLineData> {

  const CurvedLineRenderer();

  @override
  Path toLinePath(CurvedLineData lineType, Path path, List<DataPoint> points, {bool useFy = true, bool reverse = false}) {

    final smoothness = lineType.smoothness;

    if (reverse) {
      for (int i = points.length - 1; i >= 1; i--) {
        final curr = points[i];
        final prev = points[i - 1];
        if (i == points.length - 1) {
          final controlX = prev.x + (curr.x - prev.x) * smoothness;
          path.quadraticBezierTo(controlX, curr.getYorFY(useFy), prev.x, prev.getYorFY(useFy));
        } else if (i == 1) {
          final controlX = curr.x - (curr.x - prev.x) * smoothness;
          path.quadraticBezierTo(controlX, prev.getYorFY(useFy), prev.x, prev.getYorFY(useFy));
        } else {
          final next = points[i + 1];
          final controlX1 = curr.x - (curr.x - next.x) * smoothness;
          final controlX2 = prev.x + (curr.x - prev.x) * smoothness;
          path.cubicTo(controlX1, curr.getYorFY(useFy), controlX2, prev.getYorFY(useFy), prev.x, prev.getYorFY(useFy));
        }
      }
    } else {
      for (int i = 1; i < points.length; i++) {
        final prev = points[i - 1];
        final curr = points[i];

        if (i == 1) {
          final controlX = prev.x + (curr.x - prev.x) * smoothness;
          path.quadraticBezierTo(controlX, prev.getYorFY(useFy), curr.x, curr.getYorFY(useFy));
        } else if (i == points.length - 1) {
          final controlX = curr.x - (curr.x - prev.x) * smoothness;
          path.quadraticBezierTo(controlX, curr.getYorFY(useFy), curr.x, curr.getYorFY(useFy));
        } else {
          final next = points[i + 1];
          final controlX1 = prev.x + (curr.x - prev.x) * smoothness;
          final controlX2 = curr.x - (next.x - curr.x) * smoothness;
          path.cubicTo(controlX1, prev.getYorFY(useFy), controlX2, curr.getYorFY(useFy), curr.x, curr.getYorFY(useFy));
        }
      }
    }

    return path;
  }

  @override
  void renderComplexPath(ChartRenderContext context, LineData lineData, bool isDynamicStroke, bool isDynamicPaint) {
  }
}


class SteppedLineRenderer extends BaseLineTypeRenderer<SteppedLineData> {

  const SteppedLineRenderer();

  @override
  Path toLinePath(SteppedLineData lineType, Path path, List<DataPoint> points, {bool useFy = true, bool reverse = false}) {

    if (reverse) {
      for (int i = points.length - 1; i >= 1; i--) {
        final curr = points[i];
        final prev = points[i - 1];
        final stepX = prev.x + (curr.x - prev.x) * lineType.stepJumpAt;
        path.lineTo(stepX, curr.getYorFY(useFy));
        path.lineTo(stepX, prev.getYorFY(useFy));
        path.lineTo(prev.x, prev.getYorFY(useFy));
      }
    } else {
      for (int i = 1; i < points.length; i++) {
        final prev = points[i - 1];
        final curr = points[i];
        final stepX = prev.x + (curr.x - prev.x) * lineType.stepJumpAt;
        path.lineTo(stepX, prev.getYorFY(useFy));
        path.lineTo(stepX, curr.getYorFY(useFy));
        path.lineTo(curr.x, curr.getYorFY(useFy));
      }
    }

    return path;
  }

  /// When some size or color is dynamic rendering stepped line as separate intervals:
  ///   Joins - vertical lines (jumps between prev.fy and next.fy) - using "global" thickness
  ///   Values - horizontal lines (value lines) - using "local" thickness
  @override
  void renderComplexPath(ChartRenderContext context, LineData lineData, bool isDynamicStroke, bool isDynamicPaint) {

    final lineType = lineData.lineType as SteppedLineData;
    final points = lineData.points;
    final halfJoin = context.toScreenLength(lineData.thickness.size) / 2;
    final isCapRound = lineType.isStrokeCapRound;
    final isJoinRound = lineType.isStrokeJoinRound;

    // Precompute stepX for each interval (stepX[i] = join x between points[i] and points[i+1])
    final stepX = <double>[];
    for (int i = 0; i < points.length - 1; i++) {
      final prev = points[i];
      final curr = points[i + 1];
      stepX.add(prev.x + (curr.x - prev.x) * lineType.stepJumpAt);
    }


    // Drawing joins (vertical lines) with global thickness
    // When isStrokeCapRound: offset from top and bottom by halfJoin to align with rounded value line ends
    final Paint joinsPaint = buildPaint(context, lineData);
    // if (!isDynamicPaint) {
    //   final path = Path();
    //
    //   final globalHalf = halfJoin;
    //   final radius = halfJoin;
    //
    //   final screenPoints =
    //   points.map((p) => context.transformXY(p.x, p.fy)).toList();
    //
    //   final stepScreenX = <double>[];
    //   for (int i = 0; i < stepX.length; i++) {
    //     final p = context.transformXY(stepX[i], points[i].fy);
    //     stepScreenX.add(p.dx);
    //   }
    //
    //   // =======================
    //   // TOP CONTOUR
    //   // =======================
    //
    //   for (int i = 0; i < screenPoints.length; i++) {
    //     final curr = screenPoints[i];
    //
    //     final halfLocal =
    //         context.toScreenLength(points[i].thickness?.size ?? lineData.thickness.size) / 2;
    //
    //     final topY = curr.dy - halfLocal;
    //
    //     final leftX = (i == 0)
    //         ? curr.dx
    //         : stepScreenX[i - 1] - globalHalf;
    //
    //     final rightX = (i == screenPoints.length - 1)
    //         ? curr.dx
    //         : stepScreenX[i] + globalHalf;
    //
    //     if (i == 0) {
    //       path.moveTo(leftX, topY);
    //     }
    //
    //     // Horizontal
    //     path.lineTo(rightX, topY);
    //
    //     if (i < screenPoints.length - 1) {
    //       final next = screenPoints[i + 1];
    //
    //       final nextHalf =
    //           context.toScreenLength(points[i + 1].thickness?.size ?? lineData.thickness.size) / 2;
    //
    //       final nextTopY = next.dy - nextHalf;
    //
    //       final verticalX = stepScreenX[i] + globalHalf;
    //
    //       // Vertical
    //       if (!isJoinRound) {
    //         path.lineTo(verticalX, nextTopY);
    //       } else {
    //         final goingUp = next.dy < curr.dy;
    //
    //         if (goingUp) {
    //           path.arcToPoint(
    //             Offset(verticalX, nextTopY),
    //             radius: Radius.circular(radius),
    //             clockwise: false,
    //           );
    //         } else {
    //           path.arcToPoint(
    //             Offset(verticalX, nextTopY),
    //             radius: Radius.circular(radius),
    //             clockwise: true,
    //           );
    //         }
    //       }
    //     }
    //   }
    //
    //   // =======================
    //   // BOTTOM CONTOUR (reverse)
    //   // =======================
    //
    //   for (int i = screenPoints.length - 1; i >= 0; i--) {
    //     final curr = screenPoints[i];
    //
    //     final halfLocal =
    //         context.toScreenLength(points[i].thickness?.size ?? lineData.thickness.size) / 2;
    //
    //     final bottomY = curr.dy + halfLocal;
    //
    //     final leftX = (i == 0)
    //         ? curr.dx
    //         : stepScreenX[i - 1] - globalHalf;
    //
    //     final rightX = (i == screenPoints.length - 1)
    //         ? curr.dx
    //         : stepScreenX[i] + globalHalf;
    //
    //     // Horizontal
    //     path.lineTo(leftX, bottomY);
    //
    //     if (i > 0) {
    //       final prev = screenPoints[i - 1];
    //
    //       final prevHalf =
    //           context.toScreenLength(points[i - 1].thickness?.size ?? lineData.thickness.size) / 2;
    //
    //       final prevBottomY = prev.dy + prevHalf;
    //
    //       final verticalX = stepScreenX[i - 1] - globalHalf;
    //
    //       if (!isJoinRound) {
    //         path.lineTo(verticalX, prevBottomY);
    //       } else {
    //         final goingUp = curr.dy < prev.dy;
    //
    //         if (goingUp) {
    //           path.arcToPoint(
    //             Offset(verticalX, prevBottomY),
    //             radius: Radius.circular(radius),
    //             clockwise: true,
    //           );
    //         } else {
    //           path.arcToPoint(
    //             Offset(verticalX, prevBottomY),
    //             radius: Radius.circular(radius),
    //             clockwise: false,
    //           );
    //         }
    //       }
    //     }
    //   }
    //
    //   path.close();
    //
    //   final paint = Paint()..style = PaintingStyle.fill;
    //   paintThickness(paint, path.getBounds(), lineData.thickness);
    //   context.canvas.drawPath(path, paint);
    //
    //   return;
    // }


    final joinsPath = Path();
    for (int i = 0; i < stepX.length; i++) {
      final yMin = points[i].fy < points[i + 1].fy ? points[i].fy : points[i + 1].fy;
      final yMax = points[i].fy < points[i + 1].fy ? points[i + 1].fy : points[i].fy;
      final top = isCapRound ? yMin + halfJoin : yMin;
      final bottom = isCapRound ? yMax - halfJoin : yMax;
      if (bottom > top) {
        joinsPath.moveTo(stepX[i], top);
        joinsPath.lineTo(stepX[i], bottom);
      }
    }
    final tJoinsPath = joinsPath.transform(context.pathTransform.storage);
    paintThickness(joinsPaint, tJoinsPath.getBounds(), lineData.thickness);
    context.canvas.drawPath(tJoinsPath, joinsPaint);

    // Draw value lines as filled rectangles with rounded corners (uniform thickness in screen space)
    for (int i = 0; i < points.length; i++) {
      final valueSize = points[i].thickness?.size ?? lineData.thickness.size;
      final leftEnd = i == 0 ? points[0].x : stepX[i - 1] - halfJoin;
      final rightEnd = i == points.length - 1 ? points[i].x : stepX[i] + halfJoin;

      final left = context.transformXY(leftEnd, points[i].fy);
      final right = context.transformXY(rightEnd, points[i].fy);
      final screenHeight = context.toScreenLength(valueSize);
      final halfScreen = screenHeight / 2;
      final centerY = (left.dy + right.dy) / 2;

      final rect = Rect.fromLTRB(
        left.dx,
        centerY - halfScreen,
        right.dx,
        centerY + halfScreen,
      );

      final screenRadius = context.toScreenLength(halfJoin).clamp(0.0, halfScreen);
      final leftRounded = (i == 0 && isCapRound) || (i > 0 && isJoinRound);
      final rightRounded = (i == points.length - 1 && isCapRound) || (i < points.length - 1 && isJoinRound);

      final rrect = RRect.fromRectAndCorners(
        rect,
        topLeft: leftRounded ? Radius.circular(screenRadius) : Radius.zero,
        bottomLeft: leftRounded ? Radius.circular(screenRadius) : Radius.zero,
        topRight: rightRounded ? Radius.circular(screenRadius) : Radius.zero,
        bottomRight: rightRounded ? Radius.circular(screenRadius) : Radius.zero,
      );

      final valuePath = Path()..addRRect(rrect);
      final paint = Paint()
        ..style = PaintingStyle.fill
        ..strokeWidth = 0;
      paintThickness(paint, rect, lineData.thickness, points[i].thickness);
      context.canvas.drawPath(valuePath, paint);
    }
  }


}


// class _RoundJoinMarker extends Offset {
//   final Offset center;
//   final double radius;
//   final bool isTop;
//   final Offset n1;
//   final Offset n2;
//
//   _RoundJoinMarker(
//       this.center,
//       this.radius,
//       this.isTop,
//       this.n1,
//       this.n2,
//       ) : super(center.dx, center.dy);
// }