import 'dart:math' as math;
import 'dart:ui';

const _epsilon = 0.001;

// Expecting that inner ellipse is inside outer
class EllipseArcBuilder {

  Offset innerAxisX;
  Offset innerAxisY;
  Offset outerAxisX;
  Offset outerAxisY;

  double startAngle;
  double endAngle;
  double padAngle;
  double cornerRadius;
  double? padRadius;

  EllipseArcBuilder({
    required this.innerAxisX,
    required this.innerAxisY,
    required this.outerAxisX,
    required this.outerAxisY,
    required this.startAngle,
    required this.endAngle,
    required this.padAngle,
    required this.cornerRadius,
    this.padRadius
  });

}

