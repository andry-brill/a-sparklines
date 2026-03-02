/// Chart flip: none, vertically, horizontally, or both.
/// Vertically flips around horizontal axis; horizontally flips around vertical axis.
enum ChartFlip {

  none,
  vertically,
  horizontally,
  both;

  static const ChartFlip
    acrossY = horizontally,
    acrossX = vertically,
    acrossXY = both;
}
