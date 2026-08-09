abstract interface class ISeatLabelBuilder {

  /// Return the label for the next emitted seat.
  String? next(int row, int column, Object? area);

  /// Validate the completed build and reset any per-build state.
  void validate();

}

class NullLabels implements ISeatLabelBuilder {

  const NullLabels();

  @override
  String? next(int row, int column, Object? area) => null;

  @override
  void validate() {}

}

class ListLabels implements ISeatLabelBuilder {

  final List<String> labels;

  int _index = 0;

  ListLabels(List<String> labels) : labels = List<String>.unmodifiable(labels);

  @override
  String next(int row, int column, Object? area) {
    if (_index >= labels.length) {
      _index = 0;
      throw StateError('No label remains for the seat at row $row and column $column');
    }
    return labels[_index++];
  }

  @override
  void validate() {
    final used = _index;
    _index = 0;
    if (used != labels.length) {
      throw StateError('Expected all ${labels.length} seat labels to be used, but used $used');
    }
  }

}
