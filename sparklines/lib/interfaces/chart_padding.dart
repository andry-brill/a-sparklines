import 'package:flutter/foundation.dart';

import 'length_value.dart';

/// Screen-space padding applied inside the chart viewport.
@immutable
class ChartPadding {

  final ILengthValue? left;
  final ILengthValue? top;
  final ILengthValue? right;
  final ILengthValue? bottom;

  const ChartPadding({
    this.left,
    this.top,
    this.right,
    this.bottom,
  });

  bool get isEmpty => left == null && top == null && right == null && bottom == null;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ChartPadding &&
      left == other.left &&
      top == other.top &&
      right == other.right &&
      bottom == other.bottom;
  }

  @override
  int get hashCode => Object.hash(left, top, right, bottom);

}
