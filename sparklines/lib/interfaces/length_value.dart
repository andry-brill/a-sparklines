/// Resolves unit-aware visual lengths for a chart's current viewport and data
/// transform.
abstract interface class ILengthContext {
  /// Logical viewport width for the chart, after its rotation dimension swap.
  double get viewportWidth;

  /// Logical viewport height for the chart, after its rotation dimension swap.
  double get viewportHeight;

  /// Converts an X-axis data-space interval to a screen-space magnitude.
  double dataX(double value);

  /// Converts a Y-axis data-space interval to a screen-space magnitude.
  double dataY(double value);
}

/// A visual length that is resolved only when the chart transform is known.
abstract interface class ILengthValue {
  double resolve(ILengthContext context);

  /// Interpolates two potentially different length units after they resolve.
  ///
  /// A missing endpoint is treated as a zero-pixel length while the animation
  /// is in progress. Exact endpoints retain their original nullable values.
  static ILengthValue? lerp(
    ILengthValue? from,
    ILengthValue? to,
    double t,
  ) {
    if (t <= 0.0) return from;
    if (t >= 1.0) return to;
    if (from == null && to == null) return null;
    if (from == to) return from;
    return Lp(from ?? const Px(0), to ?? const Px(0), t);
  }
}

abstract class _SingleLengthValue implements ILengthValue {
  final double value;

  const _SingleLengthValue(this.value);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other.runtimeType == runtimeType &&
            other is _SingleLengthValue &&
            other.value == value;
  }

  @override
  int get hashCode => Object.hash(runtimeType, value);
}

/// A length measured in Flutter logical pixels.
final class Px extends _SingleLengthValue {
  const Px(super.value);

  @override
  double resolve(ILengthContext context) => value;
}

/// A CSS-style percentage of the logical viewport width (`Vw(1)` is 1%).
final class Vw extends _SingleLengthValue {
  const Vw(super.value);

  @override
  double resolve(ILengthContext context) => context.viewportWidth * value / 100;
}

/// A CSS-style percentage of the logical viewport height (`Vh(1)` is 1%).
final class Vh extends _SingleLengthValue {
  const Vh(super.value);

  @override
  double resolve(ILengthContext context) =>
      context.viewportHeight * value / 100;
}

/// A percentage of the shorter logical viewport dimension (`Vmin(1)` is 1%).
final class Vmin extends _SingleLengthValue {
  const Vmin(super.value);

  @override
  double resolve(ILengthContext context) {
    final side = context.viewportWidth < context.viewportHeight
        ? context.viewportWidth
        : context.viewportHeight;
    return side * value / 100;
  }
}

/// A percentage of the longer logical viewport dimension (`Vmax(1)` is 1%).
final class Vmax extends _SingleLengthValue {
  const Vmax(super.value);

  @override
  double resolve(ILengthContext context) {
    final side = context.viewportWidth > context.viewportHeight
        ? context.viewportWidth
        : context.viewportHeight;
    return side * value / 100;
  }
}

/// A length measured as an X-axis data-space interval.
final class Dx extends _SingleLengthValue {
  const Dx(super.value);

  @override
  double resolve(ILengthContext context) => context.dataX(value);
}

/// A length measured as a Y-axis data-space interval.
final class Dy extends _SingleLengthValue {
  const Dy(super.value);

  @override
  double resolve(ILengthContext context) => context.dataY(value);
}

/// Deferred interpolation between two length values.
///
/// This implementation is intentionally omitted from the package barrel; use
/// [ILengthValue.lerp] instead of constructing it directly.
final class Lp implements ILengthValue {
  final ILengthValue a;
  final ILengthValue b;
  final double t;

  const Lp(this.a, this.b, this.t);

  @override
  double resolve(ILengthContext context) {
    final av = a.resolve(context);
    final bv = b.resolve(context);
    return av + (bv - av) * t;
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is Lp && other.a == a && other.b == b && other.t == t;
  }

  @override
  int get hashCode => Object.hash(a, b, t);
}
