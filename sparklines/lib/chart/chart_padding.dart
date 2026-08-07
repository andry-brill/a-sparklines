import 'dart:math' as math;

import 'package:vector_math/vector_math_64.dart';

import '../interfaces/chart_padding.dart';
import '../interfaces/chart_transform.dart';
import '../interfaces/layout.dart';

Matrix4 paddedChartMatrix(Matrix4 preliminary, ILayoutData dimensions, ChartPadding padding) {
  if (padding.isEmpty || dimensions.width <= 0.0 || dimensions.height <= 0.0) return preliminary;

  final transform = ChartTransform(dimensions: dimensions, pathTransform: preliminary);
  final left = math.max(0.0, padding.left == null ? 0.0 : transform.length(padding.left!));
  final top = math.max(0.0, padding.top == null ? 0.0 : transform.length(padding.top!));
  final right = math.max(0.0, padding.right == null ? 0.0 : transform.length(padding.right!));
  final bottom = math.max(0.0, padding.bottom == null ? 0.0 : transform.length(padding.bottom!));
  final innerWidth = math.max(0.0, dimensions.width - left - right);
  final innerHeight = math.max(0.0, dimensions.height - top - bottom);

  return Matrix4.identity()
    ..translateByVector3(Vector3(left, top, 0.0))
    ..scaleByVector3(Vector3(innerWidth / dimensions.width, innerHeight / dimensions.height, 1.0))
    ..multiply(preliminary);
}
