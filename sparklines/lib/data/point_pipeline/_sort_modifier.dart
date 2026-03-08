part of 'data_point_pipeline.dart';


class _SortModifier implements DataPointModifier {

  final bool? x;
  final bool? y;
  final bool? fy;

  const _SortModifier({this.x, this.y, this.fy});

  @override
  List<DataPoint> apply(
      List<DataPoint> input,
      DataPointPipelineContext context,
      ) {
    if (input.isEmpty) return input;

    final allNull = x == null && y == null && fy == null;
    final sortX = x ?? (allNull ? true : null);
    final sortY = y;
    final sortFy = fy;

    final result = List<DataPoint>.from(input);

    result.sort((a, b) {
      if (sortX != null) {
        final c = sortX ? a.x.compareTo(b.x) : b.x.compareTo(a.x);
        if (c != 0) return c;
      }
      if (sortY != null) {
        final c = sortY ? a.y.compareTo(b.y) : b.y.compareTo(a.y);
        if (c != 0) return c;
      }
      if (sortFy != null) {
        final c = sortFy ? a.fy.compareTo(b.fy) : b.fy.compareTo(a.fy);
        if (c != 0) return c;
      }
      return 0;
    });

    return result;
  }
}
