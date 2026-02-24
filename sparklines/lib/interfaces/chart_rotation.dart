import 'dart:math';

/// Chart rotation: 0°, 90°, 180°, 270° (clockwise). For d90 and d270 the chart
/// is laid out with width and height swapped so it fills the bounds when rotated.
enum ChartRotation {
  d0,
  d90,
  d180,
  d270;

  double get angle => switch (this) {
        ChartRotation.d0 => 0.0,
        ChartRotation.d90 => pi / 2,
        ChartRotation.d180 => pi,
        ChartRotation.d270 => 3 * pi / 2,
      };
}
