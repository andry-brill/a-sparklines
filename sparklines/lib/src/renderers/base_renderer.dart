import 'package:flutter/material.dart';
import '../coordinate_transformer.dart';
import '../interfaces.dart';

/// Base class for all chart renderers
abstract class BaseRenderer {
  /// Render the chart to the canvas
  void render(
    Canvas canvas,
    CoordinateTransformer transformer,
    ISparklinesData data,
  );
}
