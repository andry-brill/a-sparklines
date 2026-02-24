/// Interface for types that can be interpolated
abstract class ILerpTo<T> {
  /// Interpolate between this and [next] using interpolation factor [t] (0.0 to 1.0)
  T lerpTo(T next, double t);

  static L? lerp<L extends ILerpTo<L>>(L? from, L? to, double t) {
    return from != null && to != null ? from.lerpTo(to, t) : to;
  }
}
