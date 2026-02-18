import 'dart:math';

import 'package:flutter/material.dart';
import 'package:sparklines/src/data/data_point.dart';
import 'package:sparklines/src/interfaces.dart';
import 'package:vector_math/vector_math_64.dart';

import '../../data/line_data.dart';
import 'base_line_type_renderer.dart';

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
    final Paint joinsPaint = buildStrokePaint(context, lineData);
    if (!isDynamicPaint) {

      final globalSize = lineData.thickness.size;
      final globalHalfScreen = context.toScreenLength(globalSize) / 2;

      // ---- Build centerline in data space ----
      final ctrl = <Vector3>[
        Vector3(points[0].x, points[0].fy, 0),
      ];

      for (int i = 0; i < stepX.length; i++) {
        ctrl.add(Vector3(stepX[i], points[i].fy, 0));
        ctrl.add(Vector3(stepX[i], points[i + 1].fy, 0));
        ctrl.add(Vector3(points[i + 1].x, points[i + 1].fy, 0));
      }

      // ---- Transform to screen space ----
      final screen = ctrl
          .map((v) => context.pathTransform.transform3(v))
          .map((v) => Offset(v.x, v.y))
          .toList();

      final segCount = screen.length - 1;

      // ---- Compute effective half thickness per segment ----
      final halfScreen = <double>[];

      for (int i = 0; i < stepX.length; i++) {

        // Expecting that local half >= global half
        final localHalf0 = max(globalHalfScreen, context.toScreenLength(
          (points[i].thickness?.size ?? globalSize) / 2,
        ));

        final localHalf1 = max(globalHalfScreen, context.toScreenLength(
          (points[i + 1].thickness?.size ?? globalSize) / 2,
        ));

        // subtract global half
        halfScreen.add((localHalf0 - globalHalfScreen).clamp(0.0, double.infinity));
        halfScreen.add(0); // vertical join uses only global stroke
        halfScreen.add((localHalf1 - globalHalfScreen).clamp(0.0, double.infinity));
      }

      final topPoints = <Offset>[];
      final bottomPoints = <Offset>[];

      Offset normalOf(Offset a, Offset b) {
        final dx = b.dx - a.dx;
        final dy = b.dy - a.dy;

        if (dx.abs() > dy.abs()) {
          return dx > 0
              ? const Offset(0, -1)
              : const Offset(0, 1);
        } else {
          return dy > 0
              ? const Offset(1, 0)
              : const Offset(-1, 0);
        }
      }

      // ---- First segment ----
          {
        final n = normalOf(screen[0], screen[1]);
        final h = halfScreen[0];

        topPoints.add(screen[0] + n * h);
        bottomPoints.add(screen[0] - n * h);
      }

      // ---- Interior vertices ----
      for (int i = 1; i < segCount; i++) {

        final pPrev = screen[i - 1];
        final pCurr = screen[i];
        final pNext = screen[i + 1];

        final n1 = normalOf(pPrev, pCurr);
        final n2 = normalOf(pCurr, pNext);

        final h1 = halfScreen[i - 1];
        final h2 = halfScreen[i];

        final a = pCurr + n1 * h1;
        final b = pCurr - n1 * h1;

        final c = pCurr + n2 * h2;
        final d = pCurr - n2 * h2;

        Offset topJoin;
        Offset bottomJoin;

        if (n1.dx != 0) {
          topJoin = Offset(a.dx, c.dy);
          bottomJoin = Offset(b.dx, d.dy);
        } else {
          topJoin = Offset(c.dx, a.dy);
          bottomJoin = Offset(d.dx, b.dy);
        }

        topPoints.add(topJoin);
        bottomPoints.add(bottomJoin);
      }

      // ---- Last segment ----
          {
        final n = normalOf(screen[segCount - 1], screen[segCount]);
        final h = halfScreen[segCount - 1];

        topPoints.add(screen[segCount] + n * h);
        bottomPoints.add(screen[segCount] - n * h);
      }

      // ---- Build inner fill path ----
      final path = Path();
      path.moveTo(topPoints.first.dx, topPoints.first.dy);

      for (int i = 1; i < topPoints.length; i++) {
        path.lineTo(topPoints[i].dx, topPoints[i].dy);
      }

      for (int i = bottomPoints.length - 1; i >= 0; i--) {
        path.lineTo(bottomPoints[i].dx, bottomPoints[i].dy);
      }

      path.close();

      final fillPaint = buildFillPaint(context, lineData);
      paintThickness(fillPaint, path.getBounds(), lineData.thickness);
      context.canvas.drawPath(path, fillPaint);

      final strokePaint = buildStrokePaint(context, lineData);
      paintThickness(strokePaint, path.getBounds(), lineData.thickness);
      context.canvas.drawPath(path, strokePaint);

      return;
    }


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
