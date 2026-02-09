import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:sparklines/src/data/pie_data.dart';
import 'package:sparklines/src/data/pie_slice_layout.dart';
import 'package:sparklines/src/renderers/chart_renderer.dart';
import 'package:sparklines/src/layout/coordinate_transformer.dart';

/// Renders pie charts. Slices are like bars: axis is the ray from origin
/// through (x,y); dy is extent along that ray. Space is uniform gap between
/// slices. Border and borderRadius per piece match bar behavior.
class PieChartRenderer extends AChartRenderer<PieData> {

  @override
  void renderData(
    Canvas canvas,
    CoordinateTransformer transformer,
    PieData pieData,
  ) {
    final layout = computePieSliceLayout(
      pieData.points,
      pieData.space,
      pieData.thickness.size,
      pieData.thickness.align,
    );
    if (layout.isEmpty) return;

    final paint = Paint();

    for (final s in layout) {
      final path = _sectorPath(
        transformer,
        s.startAngle,
        s.endAngle,
        s.innerRadius,
        s.outerRadius,
        s.spaceOffset,
        pieData.borderRadius != null && pieData.borderRadius! > 0
            ? transformer.transformDimension(pieData.borderRadius!)
            : null,
      );
      if (path == null) continue;

      // Fill from thickness (gradient takes priority over color)
      paint.style = PaintingStyle.fill;
      if (pieData.thickness.gradient != null) {
        final cx = transformer.transformX(s.spaceOffset.dx);
        final cy = transformer.transformY(s.spaceOffset.dy);
        final rx = (transformer.transformX(s.spaceOffset.dx + s.outerRadius) - cx).abs();
        final ry = (transformer.transformY(s.spaceOffset.dy + s.outerRadius) - cy).abs();
        paint.shader = pieData.thickness.gradient!.createShader(
          Rect.fromCircle(center: Offset(cx, cy), radius: math.max(rx, ry)),
        );
      } else {
        paint.shader = null;
        paint.color = pieData.thickness.color;
      }
      canvas.drawPath(path, paint);

      // Border (same idea as bars: stroke around piece)
      final border = pieData.border;
      if (border != null) {
        final borderSize = transformer.transformDimension(border.size);
        paint.style = PaintingStyle.stroke;
        paint.strokeWidth = borderSize;
        if (border.gradient != null) {
          final cx = transformer.transformX(s.spaceOffset.dx);
          final cy = transformer.transformY(s.spaceOffset.dy);
          final rx = (transformer.transformX(s.spaceOffset.dx + s.outerRadius) - cx).abs();
          final ry = (transformer.transformY(s.spaceOffset.dy + s.outerRadius) - cy).abs();
          paint.shader = border.gradient!.createShader(
            Rect.fromCircle(center: Offset(cx, cy), radius: math.max(rx, ry)),
          );
        } else {
          paint.shader = null;
          paint.color = border.color;
        }
        canvas.drawPath(path, paint);
      }
    }
  }

  /// Builds sector path in screen coordinates. Returns null if sector is degenerate.
  Path? _sectorPath(
    CoordinateTransformer transformer,
    double startAngle,
    double endAngle,
    double innerRadius,
    double outerRadius,
    Offset spaceOffset,
    double? cornerRadiusScreen,
  ) {
    final sweep = endAngle - startAngle;
    if (sweep <= 0 || outerRadius <= 0) return null;

    double tx(double dx) => transformer.transformX(spaceOffset.dx + dx);
    double ty(double dy) => transformer.transformY(spaceOffset.dy + dy);
    final cx = tx(0), cy = ty(0);
    final screenOuterW = 2 * (tx(outerRadius) - cx).abs();
    final screenOuterH = 2 * (ty(outerRadius) - cy).abs();
    final screenInnerW = innerRadius > 0 ? 2 * (tx(innerRadius) - cx).abs() : 0.0;
    final screenInnerH = innerRadius > 0 ? 2 * (ty(innerRadius) - cy).abs() : 0.0;

    final path = Path();

    if (innerRadius <= 0) {
      // Full sector (center to outer arc)
      if (cornerRadiusScreen != null && cornerRadiusScreen > 0) {
        _appendRoundedSectorToPath(
          path, tx, ty, cx, cy, outerRadius, startAngle, endAngle,
          math.min(cornerRadiusScreen, screenOuterW / 4),
        );
      } else {
        path.moveTo(cx, cy);
        path.arcTo(
          Rect.fromCenter(center: Offset(cx, cy), width: screenOuterW, height: screenOuterH),
          startAngle,
          sweep,
          false,
        );
        path.close();
      }
    } else {
      // Annular sector
      if (cornerRadiusScreen != null && cornerRadiusScreen > 0) {
        _appendRoundedAnnularSectorToPath(
          path, cx, cy, screenInnerW, screenInnerH, screenOuterW, screenOuterH,
          startAngle, endAngle,
          math.min(cornerRadiusScreen, screenOuterW / 4),
        );
      } else {
        path.moveTo(
          cx + (screenOuterW / 2) * math.cos(startAngle),
          cy - (screenOuterH / 2) * math.sin(startAngle),
        );
        path.arcTo(
          Rect.fromCenter(center: Offset(cx, cy), width: screenOuterW, height: screenOuterH),
          startAngle,
          sweep,
          false,
        );
        path.arcTo(
          Rect.fromCenter(center: Offset(cx, cy), width: screenInnerW, height: screenInnerH),
          endAngle,
          -sweep,
          false,
        );
        path.close();
      }
    }

    return path;
  }

  void _appendRoundedSectorToPath(
    Path path,
    double Function(double) tx,
    double Function(double) ty,
    double cx,
    double cy,
    double outerR,
    double startAngle,
    double endAngle,
    double cornerRadius,
  ) {
    final startX = tx(outerR * math.cos(startAngle));
    final startY = ty(outerR * math.sin(startAngle));
    final endX = tx(outerR * math.cos(endAngle));
    final endY = ty(outerR * math.sin(endAngle));
    path.moveTo(cx, cy);
    final cr = math.min(cornerRadius, outerR * 0.5);
    final innerStartX = tx((outerR - cr) * math.cos(startAngle));
    final innerStartY = ty((outerR - cr) * math.sin(startAngle));
    path.lineTo(innerStartX, innerStartY);
    path.quadraticBezierTo(startX, startY, startX, startY);
    final screenOuterW = 2 * (tx(outerR) - cx).abs();
    final screenOuterH = 2 * (ty(outerR) - cy).abs();
    path.arcTo(
      Rect.fromCenter(center: Offset(cx, cy), width: screenOuterW, height: screenOuterH),
      startAngle,
      endAngle - startAngle,
      false,
    );
    final innerEndX = tx((outerR - cr) * math.cos(endAngle));
    final innerEndY = ty((outerR - cr) * math.sin(endAngle));
    path.quadraticBezierTo(endX, endY, innerEndX, innerEndY);
    path.close();
  }

  void _appendRoundedAnnularSectorToPath(
    Path path,
    double cx,
    double cy,
    double screenInnerW,
    double screenInnerH,
    double screenOuterW,
    double screenOuterH,
    double startAngle,
    double endAngle,
    double cornerRadius,
  ) {
    final sweep = endAngle - startAngle;
    final startOutX = cx + (screenOuterW / 2) * math.cos(startAngle);
    final startOutY = cy - (screenOuterH / 2) * math.sin(startAngle);
    path.moveTo(startOutX, startOutY);
    path.arcTo(
      Rect.fromCenter(center: Offset(cx, cy), width: screenOuterW, height: screenOuterH),
      startAngle,
      sweep,
      false,
    );
    path.arcTo(
      Rect.fromCenter(center: Offset(cx, cy), width: screenInnerW, height: screenInnerH),
      endAngle,
      -sweep,
      false,
    );
    path.close();
  }
}
