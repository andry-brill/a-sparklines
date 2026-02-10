import 'package:flutter/material.dart';
import 'package:sparklines/src/data/pie_data.dart';
import 'package:sparklines/src/data/pie_slice_layout.dart';
import 'package:sparklines/src/renderers/chart_renderer.dart';
import 'package:sparklines/src/layout/coordinate_transformer.dart';
import 'package:sparklines/src/layout/arc_builder.dart';

/// Screen-space pie slice: center and radii/dimensions already in pixel coordinates.
class _ScreenPieSlice {
  final Offset center;
  final double innerRadius;
  final double outerRadius;
  final double startAngle;
  final double endAngle;
  final double cornerRadius;
  final double? borderSize;

  const _ScreenPieSlice({
    required this.center,
    required this.innerRadius,
    required this.outerRadius,
    required this.startAngle,
    required this.endAngle,
    required this.cornerRadius,
    this.borderSize,
  });
}

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
      transformer: transformer,
    );
    if (layout.isEmpty) return;

    final screenSlices = _toScreenSlices(
      layout,
      transformer,
      pieData.borderRadius,
      pieData.border?.size,
    );

    final paint = Paint();

    for (final s in screenSlices) {
      final path = _sectorPath2(s);
      if (path == null) continue;

      paint.style = PaintingStyle.fill;
      if (pieData.thickness.gradient != null) {
        paint.shader = pieData.thickness.gradient!.createShader(
          Rect.fromCircle(center: s.center, radius: s.outerRadius),
        );
      } else {
        paint.shader = null;
        paint.color = pieData.thickness.color;
      }
      canvas.drawPath(path, paint);

      final border = pieData.border;
      if (border != null && s.borderSize != null) {
        paint.style = PaintingStyle.stroke;
        paint.strokeWidth = s.borderSize!;
        if (border.gradient != null) {
          paint.shader = border.gradient!.createShader(
            Rect.fromCircle(center: s.center, radius: s.outerRadius),
          );
        } else {
          paint.shader = null;
          paint.color = border.color;
        }
        canvas.drawPath(path, paint);
      }
    }
  }

  /// Builds screen slice from layout (already in screen space when from renderer).
  /// Only cornerRadius and borderSize are transformed here.
  static _ScreenPieSlice _toScreenSlice(
    PieSliceLayout s,
    CoordinateTransformer transformer,
    double cornerRadius,
    double? borderSize,
  ) {
    return _ScreenPieSlice(
      center: s.spaceOffset,
      innerRadius: s.innerRadius,
      outerRadius: s.outerRadius,
      startAngle: s.startAngle,
      endAngle: s.endAngle,
      cornerRadius: cornerRadius,
      borderSize: borderSize != null ? transformer.transformDimension(borderSize) : null,
    );
  }

  static List<_ScreenPieSlice> _toScreenSlices(
    List<PieSliceLayout> layout,
    CoordinateTransformer transformer,
    double? borderRadius,
    double? borderSize,
  ) {
    final cornerRadius = (borderRadius != null && borderRadius > 0)
        ? transformer.transformDimension(borderRadius)
        : 0.0;
    return layout
        .map((s) => _toScreenSlice(s, transformer, cornerRadius, borderSize))
        .toList();
  }

  /// Builds sector path in screen coordinates from an already-transformed slice.
  /// Uses [ArcBuilder] and applies [ArcBuilder.build] then shifts by slice center.
  Path? _sectorPath2(_ScreenPieSlice s) {
    if (s.outerRadius <= 0 || (s.endAngle - s.startAngle).abs() <= 0) {
      return null;
    }
    final arc = ArcBuilder(
      innerRadius: s.innerRadius,
      outerRadius: s.outerRadius,
      startAngle: s.startAngle,
      endAngle: s.endAngle,
      padAngle: 0.0,
      cornerRadius: s.cornerRadius,
      padRadius: null,
    );
    final path = arc.build();
    return path.shift(s.center);
  }
  //
  // /// Builds sector path in screen coordinates. Returns null if sector is degenerate.
  // Path? _sectorPath(
  //   CoordinateTransformer transformer,
  //   double startAngle,
  //   double endAngle,
  //   double innerRadius,
  //   double outerRadius,
  //   Offset spaceOffset,
  //   double? cornerRadiusScreen,
  // ) {
  //   final sweep = endAngle - startAngle;
  //   if (sweep <= 0 || outerRadius <= 0) return null;
  //
  //   double tx(double dx) => transformer.transformX(spaceOffset.dx + dx);
  //   double ty(double dy) => transformer.transformY(spaceOffset.dy + dy);
  //   final cx = tx(0), cy = ty(0);
  //   final screenOuterW = 2 * (tx(outerRadius) - cx).abs();
  //   final screenOuterH = 2 * (ty(outerRadius) - cy).abs();
  //   final screenInnerW = innerRadius > 0 ? 2 * (tx(innerRadius) - cx).abs() : 0.0;
  //   final screenInnerH = innerRadius > 0 ? 2 * (ty(innerRadius) - cy).abs() : 0.0;
  //
  //   final path = Path();
  //
  //   if (innerRadius <= 0) {
  //     // Full sector (center to outer arc)
  //     if (cornerRadiusScreen != null && cornerRadiusScreen > 0) {
  //       _appendRoundedSectorToPath(
  //         path, tx, ty, cx, cy, outerRadius, startAngle, endAngle,
  //         math.min(cornerRadiusScreen, screenOuterW / 4),
  //       );
  //     } else {
  //       path.moveTo(cx, cy);
  //       path.arcTo(
  //         Rect.fromCenter(center: Offset(cx, cy), width: screenOuterW, height: screenOuterH),
  //         startAngle,
  //         sweep,
  //         false,
  //       );
  //       path.close();
  //     }
  //   } else {
  //     // Annular sector
  //     if (cornerRadiusScreen != null && cornerRadiusScreen > 0) {
  //       _appendRoundedAnnularSectorToPath(
  //         path, cx, cy, screenInnerW, screenInnerH, screenOuterW, screenOuterH,
  //         startAngle, endAngle,
  //         math.min(cornerRadiusScreen, screenOuterW / 4),
  //       );
  //     } else {
  //       path.moveTo(
  //         cx + (screenOuterW / 2) * math.cos(startAngle),
  //         cy - (screenOuterH / 2) * math.sin(startAngle),
  //       );
  //       path.arcTo(
  //         Rect.fromCenter(center: Offset(cx, cy), width: screenOuterW, height: screenOuterH),
  //         startAngle,
  //         sweep,
  //         false,
  //       );
  //       path.arcTo(
  //         Rect.fromCenter(center: Offset(cx, cy), width: screenInnerW, height: screenInnerH),
  //         endAngle,
  //         -sweep,
  //         false,
  //       );
  //       path.close();
  //     }
  //   }
  //
  //   return path;
  // }
  //
  // void _appendRoundedSectorToPath(
  //   Path path,
  //   double Function(double) tx,
  //   double Function(double) ty,
  //   double cx,
  //   double cy,
  //   double outerR,
  //   double startAngle,
  //   double endAngle,
  //   double cornerRadius,
  // ) {
  //   final startX = tx(outerR * math.cos(startAngle));
  //   final startY = ty(outerR * math.sin(startAngle));
  //   final endX = tx(outerR * math.cos(endAngle));
  //   final endY = ty(outerR * math.sin(endAngle));
  //   path.moveTo(cx, cy);
  //   final cr = math.min(cornerRadius, outerR * 0.5);
  //   final innerStartX = tx((outerR - cr) * math.cos(startAngle));
  //   final innerStartY = ty((outerR - cr) * math.sin(startAngle));
  //   path.lineTo(innerStartX, innerStartY);
  //   path.quadraticBezierTo(startX, startY, startX, startY);
  //   final screenOuterW = 2 * (tx(outerR) - cx).abs();
  //   final screenOuterH = 2 * (ty(outerR) - cy).abs();
  //   path.arcTo(
  //     Rect.fromCenter(center: Offset(cx, cy), width: screenOuterW, height: screenOuterH),
  //     startAngle,
  //     endAngle - startAngle,
  //     false,
  //   );
  //   final innerEndX = tx((outerR - cr) * math.cos(endAngle));
  //   final innerEndY = ty((outerR - cr) * math.sin(endAngle));
  //   path.quadraticBezierTo(endX, endY, innerEndX, innerEndY);
  //   path.close();
  // }
  //
  // void _appendRoundedAnnularSectorToPath(
  //   Path path,
  //   double cx,
  //   double cy,
  //   double screenInnerW,
  //   double screenInnerH,
  //   double screenOuterW,
  //   double screenOuterH,
  //   double startAngle,
  //   double endAngle,
  //   double cornerRadius,
  // ) {
  //   final sweep = endAngle - startAngle;
  //   final startOutX = cx + (screenOuterW / 2) * math.cos(startAngle);
  //   final startOutY = cy - (screenOuterH / 2) * math.sin(startAngle);
  //   path.moveTo(startOutX, startOutY);
  //   path.arcTo(
  //     Rect.fromCenter(center: Offset(cx, cy), width: screenOuterW, height: screenOuterH),
  //     startAngle,
  //     sweep,
  //     false,
  //   );
  //   path.arcTo(
  //     Rect.fromCenter(center: Offset(cx, cy), width: screenInnerW, height: screenInnerH),
  //     endAngle,
  //     -sweep,
  //     false,
  //   );
  //   path.close();
  // }
}
