

import 'package:sparklines/src/interfaces.dart';

class LayoutData implements ILayoutData {

  @override
  final double minX;
  @override
  final double maxX;
  @override
  final double minY;
  @override
  final double maxY;
  @override
  final double width;
  @override
  final double height;

  const LayoutData({
    required this.minX,
    required this.maxX,
    required this.minY,
    required this.maxY,
    required this.width,
    required this.height,
  }) :
    assert(minX < maxX, 'minX must be less than maxX'),
    assert(minY < maxY, 'minY must be less than maxY');
}