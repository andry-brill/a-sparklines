# Sparklines

[![Tests](https://github.com/andry-brill/a-sparklines/actions/workflows/test.yml/badge.svg)](https://github.com/andry-brill/a-sparklines/actions/workflows/test.yml)

Feature-rich, highly optimized sparklines for Flutter. Line, scatter, bar, pie, and between-line charts with shared layouts, animation, and flexible styling.

![App Screenshot](https://raw.githubusercontent.com/andry-brill/a-sparklines/main/sparklines/example/web/example.png)

> You might also like my other packages: [any_timeago](https://pub.dev/packages/any_timeago), [any_borders](https://pub.dev/packages/any_borders)

---

## Core concepts

### Layouts

- **AbsoluteLayout** — Data coordinates map 1:1 to pixels; origin bottom-left, Y up.
- **RelativeLayout** — Data is scaled to explicit bounds. Use `RelativeLayout.normalized()` (0–1), `RelativeLayout.signed()` (-1–1), or `RelativeLayout.full()` (auto from data). Set `minX`/`maxX`/`minY`/`maxY` to `double.infinity` or `double.negativeInfinity` to derive from chart data. **Identical layout instances are resolved once and shared** across all charts using them.

Layouts transform plotted coordinates only. Visual dimensions choose their own units independently.

### Visual lengths

Thicknesses, marker radii, borders, and corner radii use **ILengthValue**:

- **Px(2)** — Flutter logical pixels.
- **Vw(1)** / **Vh(1)** — CSS-style viewport percentages; `1` means 1%.
- **Vmin(1)** / **Vmax(1)** — Percentage of the shorter/longer logical viewport dimension.
- **Dx(0.1)** / **Dy(0.1)** — X/Y data-space intervals converted through the chart transform.

```dart
LineData(
  layout: const RelativeLayout.normalized(),
  line: points,
  thickness: const ThicknessData(size: Px(2)),
  pointStyle: const CircleDataPointStyle(radius: Vw(1), color: Colors.blue),
)
```

Custom units implement `ILengthValue.resolve(ILengthContext)`:

```dart
final class Vmean implements ILengthValue {
  final double percentage;
  const Vmean(this.percentage);

  @override
  double resolve(ILengthContext context) {
    final side = (context.viewportWidth + context.viewportHeight) / 2;
    return side * percentage / 100;
  }
}
```

Unit changes animate smoothly because both endpoints are resolved in the current viewport before interpolation.

### Rotation, flip, and origin

- **ChartRotation** — `d0`, `d90`, `d180`, `d270` (clockwise). For `d90`/`d270`, logical width/height are swapped so the chart fills the widget.
- **ChartFlip** — `none`, `vertically`, `horizontally`, `both`. Flip charts around axes; applied after rotation.
- **origin** — `Offset` applied before rotation; use to position charts.

### Crop and visibility

- **crop** — When `true`, rendering is clipped to chart bounds. Chart-level `crop` overrides the widget default.
- **visible** — Per-chart; when `false`, the chart is skipped.

### Chart insets and point fitting

`ChartInsets` reserves screen-space room inside the chart viewport without changing data points or layout bounds. Each side accepts any `ILengthValue` and omitted sides have no inset. Set global insets on `SparklinesChart.padding` or additional local insets on any built-in chart data object.

```dart
SparklinesChart(
  padding: const ChartInsets(
    left: Px(8),
    top: Px(4),
    right: Px(8),
    bottom: Px(4),
  ),
  charts: [
    LineData.scatter(
      padding: const ChartInsets(left: Px(2), right: Px(2)),
      points: const [
        DataPoint(
          x: 0,
          y: 0.5,
          dy: 0,
          data: {
            IDataPointExtent: ChartInsets(left: Px(6), top: Px(6), right: Px(6), bottom: Px(6)),
          },
        ),
      ],
    ),
  ],
)
```

`ChartInsets` also implements `IDataPointExtent`, so it can describe a visual centered on a point's `(x, fy)` anchor. Point fitting is automatic: only the part of an extent that would cross a viewport edge is added. Global padding, local padding, and point overflow are combined, while charts sharing a layout use the largest requirement on each side so they remain aligned.

`Px`, `Vw`, `Vh`, `Dx`, and `Dy` values are resolved once with the preliminary chart transform, then `insetsMatrix × layoutMatrix` is used for rendering. Negative or non-finite resolved values are treated as zero. If opposing insets consume the viewport, every point collapses to a weighted position on that axis. For example, left `10` and right `40` in a width of `10` collapse x at `2`.

### DataPoint

- **x** — X coordinate.
- **key** — Optional object used to select point transformations such as keyed `scatterZ()` styles. Use `DataPointKey(id: ..., key: ..., label: ...)` when a structured key is useful.
- **y** — Base Y (e.g. stacked base).
- **dy** — Delta from base; **fy = y + dy** is the value used for drawing.
- **z** — Third dimension for weights and other visual mappings; defaults to `0` and does not affect layout bounds.
- **data** — Extensible `Map<Type, IDataPointData?>` for per-point metadata. Keys are type tokens; values implement `IDataPointData` (supports `lerpTo` for animation). Use `point.of<M>()` for type-safe access.

`DataPoint.key` accepts any object. `DataPointKey` is a convenience value object when a point needs a numeric ID, string key, label, or any combination of them:

```dart
const stockPrice = DataPoint(
  x: 0,
  dy: 187.44,
  key: DataPointKey(id: 42, key: 'AAPL', label: 'Apple Inc.'),
);

final instrumentKey = stockPrice.key as DataPointKey;
```

`DataPointKey` has value equality, so equivalent keys can be used in sets passed to keyed pipeline operations such as `scatterZ(keys: ...)`. During point interpolation, the source key is retained at `t <= 0`; the destination key is used afterward.

**Common data entries** (via extension getters or `of<M>()`):

- **style** — `IDataPointStyle?` (e.g. `CircleDataPointStyle`) for point markers.
- **thickness** — `IThicknessOverride?` (size, color, gradient, align) to override chart thickness for this point.
- **extent** — `IDataPointExtent?`; use `ChartInsets` to automatically fit a visual centered on `(x, fy)` inside the viewport.
- **pieOffset** — `IPieOffset?` for pie slice offset.

Every `ISparklinesData` is iterable over its source points. Line, scatter, bar, and pie data iterate their corresponding point list. `BetweenLineData` iterates its `from` points followed by its `to` points, but reports `supportsPointExtents == false`, so metadata on those child points does not affect fitting.

### Thickness (global and per-point)

- **ThicknessData** — `size` (`ILengthValue`), `color`, optional `gradient` (overrides color), `align`: `ThicknessData.alignInside` (-1), `alignCenter` (0), `alignOutside` (1).
- **ThicknessOverride** on `DataPoint` — Same fields; overrides chart thickness for that point.

### Border and border radius

- **IChartBorder** — `border` (`ThicknessData?`), `borderRadius` (`ILengthValue?`). Used by **BarData** and **PieData**.

### Area fill (line charts)

- **areaColor** / **areaGradient** — Fill below the line (from line down to base Y). Gradient takes precedence over color.
- **areaFillType** — Optional `PathFillType` for the fill.

---

## Line charts

**LineData** — `line`, `thickness`, `areaColor`/`areaGradient`, `areaFillType`, `lineType`, `pointStyle`.

**LineData.scatter** — Marker-only x/y data without connected lines or area fills. It uses `const ScatterLineData()` internally. Scatter points are stored in `line`; use `y` for the vertical coordinate and set `dy` to zero so `fy = y`.

```dart
LineData.scatter(
  points: const [
    DataPoint(x: 0.0, y: 0.25, dy: 0.0),
    DataPoint(x: 0.5, y: 0.75, dy: 0.0),
    DataPoint(x: 1.0, y: 0.5, dy: 0.0),
  ],
  pointStyle: const CircleDataPointStyle(radius: Px(4), color: Colors.blue),
)
```

Use `z` with `DataPointPipeline.scatterZ()` to generate per-point styles and fitting extents:

```dart
const small = Vmin(0.5);
const large = Vmax(2);

final weightedPoints = DataPointPipeline()
    .rescaleZ()
    .scatterZ(
      style: (
        min: const CircleDataPointStyle(radius: small, color: Colors.blue),
        max: const CircleDataPointStyle(radius: large, color: Colors.red),
      ),
      extent: (
        min: const ChartInsets(left: small, top: small, right: small, bottom: small),
        max: const ChartInsets(left: large, top: large, right: large, bottom: large),
      ),
    )
    .build(points);

final weightedScatter = LineData.scatter(points: weightedPoints);
```

Use `keys` or `predicate` to style only selected points. Supplying both uses AND matching.

### Seat maps

`SeatsBuilder` records seat-layout actions and creates ordinary `DataPoint` objects only when `build()` is called.
Each point uses a `SeatKey` directly as its key. A key may include a database/display `label`, but identity remains based on `area`, `row`, and `column`; labels and stable characteristic tags do not affect equality.

```dart
enum AircraftSeatTag { extraLegroom }

final labels = ListLabels([
  for (var row = 1; row <= 10; row++)
    for (final column in ['A', 'B', 'C', 'D', 'E', 'F']) '$row$column',
]);

final rawSeats = SeatsBuilder(
  area: 'economy',
  seatDx: 1.0,
  rowDy: 1.0,
  gapDx: 0.2,
  gapDy: 0.4,
  labelBuilder: labels,
)
    .seats(3, tags: {AircraftSeatTag.extraLegroom})
    .skip(2)
    .seats(3, tags: {AircraftSeatTag.extraLegroom})
    .nextRow()
    .record()
    .seats(3)
    .skip(2)
    .seats(3)
    .nextRow()
    .repeat(9)
    .build();

final points = DataPointPipeline()
    .seats(style: availableStyle, extent: seatExtent)
    .seats(
      selector: SeatSelector(tags: {{AircraftSeatTag.extraLegroom}}),
      style: extraLegroomStyle,
    )
    .seats(keys: bookedSeats, style: bookedStyle)
    .build(rawSeats);

final seatMap = LineData.scatter(points: points);
```

`seatDx` and `rowDy` are the base slot distances.
`gapDx` and `gapDy` add persistent space between future columns and rows without moving the cursor immediately; `skip()` instead consumes complete horizontal slots and their column numbers.
`nextRow()` resets the horizontal cursor and column while retaining area, tags, data, and gap defaults.

`record()` starts a repeatable action block and `repeat(count)` closes it; the count is the total number of block executions.
Blocks may be nested. Labels default to `null` through `const NullLabels()`; provide an `ISeatLabelBuilder` to the constructor or an individual `seats()` action, or override one seat with `seat(label: ...)`.
`ListLabels` assigns its strings sequentially to emitted seats, ignores skipped slots, and validates that every supplied label was consumed. Custom builders implement `next(row, column, area)` and `validate()`; validation runs at the end of `build()`.

`area()`, `tags()`, and `data()` replace defaults for subsequent actions.
Per-call `data` overlays the default `DataPointDataMap`, with call entries winning by metadata type.
Inputs are snapshotted when their actions are recorded, and each `build()` independently interprets the complete action program.

Every `SeatSelector` field is a set. Values within `labels`, `rows`, `columns`, and `areas` use OR semantics, while different fields use AND semantics; `areas` may contain `null`.
`tags` is an OR-set of all-of groups, so `{{window, extraLegroom}, {accessible}}` means `(window AND extraLegroom) OR accessible`.
All supplied pipeline filters are combined with AND semantics, and later `seats()` decorators retain normal last-writer-wins styling behavior.

### Line types

- **LinearLineData** — Straight segments; optional `isStrokeCapRound`, `isStrokeJoinRound`.
- **SteppedLineData** — Step at fraction between points: `stepJumpAt` 0→prev, 1→next; constructors `.start()`, `.middle()`, `.end()`.
- **CurvedLineData** — Smooth curve; `smoothness` 0.0–1.0 (default 0.35).
- **ScatterLineData** — Marker-only points; `drawLine` is false and `minPoints` is 1.

Custom `ILineTypeData` implementations define `drawLine` and `minPoints`. Line and area geometry is rendered only when `drawLine` is true and the series contains at least `minPoints`; point markers render independently.

## Between-line charts

**BetweenLineData** — Fills the area between two lines. `from`, `to` (both `LineData`), `areaColor`, `areaGradient`, `areaFillType`. Uses same layout; both lines share the same coordinate system.

## Bar charts

**BarData** — `bars` (`List<DataPoint>`; `fy` = top, `y` = base), `thickness`, `border`, `borderRadius`, `pointStyle`. Bars are drawn from `y` to `fy`; use **DataPointPipeline** for stacking.

## Pie charts

**PieData** — Each **DataPoint** is one arc: **x** = radius, **y** = start angle, **dy** = sweep (end = y + dy). Angles in radians. `thickness`, `padAngle` (gap between slices), `pieOffset`, `border`, `borderRadius`, `pointStyle`. Bounds are computed from slice geometry.

---

## DataPoint pipeline

**DataPointPipeline** — Build transformed lists for stacking/normalization; reuse one pipeline for multiple series so shared state (e.g. stacking) is consistent.

- **stack({ offset?, spacing?, groupingStep? })** — Stack points by x; each point’s `y` becomes the running sum at that x, `dy` stays the value. `offset` sets the initial base for each x (default 0.0), and `spacing` adds a gap between stacked segments. By default, x values must match exactly. When `groupingStep` is provided, x values are grouped by rounding them to buckets of that size, which is useful for coordinates affected by floating-point arithmetic.
- **normalize({ total, threshold?, spacing?, trailingSpacing?, thresholdPoint? })** — Scale `dy` so sum of `abs(dy)` equals `total` (default 1.0). `threshold` repeatedly drops smallest segment until none below threshold; `thresholdPoint` receives accumulated dy of removed points. `spacing` reserves gap between segments; `trailingSpacing` adds one more spacing (useful for full pies).
- **normalize2pi({ total, threshold?, spacing?, spacingDeg?, trailingSpacing?, thresholdPoint? })** — Same as `normalize` with default `total` 2π for angles. `spacingDeg` is spacing in degrees (converted to radians); `trailingSpacing` defaults to true when `total >= 2` or `total <= -2`.
- **rescale({ currentMin?, currentMax?, targetMin, targetMax })** — Linearly rescale intervals `[DataPoint.y..DataPoint.fy]` from `[currentMin..currentMax]` to `[targetMin..targetMax]` (default 0–1). Both `y` and `fy` are transformed; `dy` is recalculated as `fy - y`. If `currentMin` or `currentMax` are not finite, they are computed from input interval bounds.
- **rescaleZ({ currentMin?, currentMax?, targetMin, targetMax, clamp })** — Linearly rescale `DataPoint.z` into a target range (default 0–1). Automatic bounds are shared across every input registered with the pipeline. Values clamp to the source range by default, and an equal source range maps to the target midpoint.
- **scatterZ({ predicate?, keys?, style, extent? })** — Interpolate `IDataPointStyle` and optional `IDataPointExtent` intervals using z clamped to 0–1, then store them in each matching point's metadata. `style` is a required `StylesInterval` record and `extent` is an optional `ExtentsInterval` record. When both `predicate` and `keys` are supplied, both must match.
- **seats({ selector?, predicate?, keys?, style, extent? })** — Apply a fixed style and optional extent to matching points whose key is a `SeatKey`. All supplied filters must match; without filters, every seat point is decorated.
- **sort({ x?, y?, fy?, z? })** — Sort input by x, y, fy, and/or z. Each: `true` = ascending, `false` = descending. If all null, sorts by x ascending.
- **aggregate({ function, window? })** — Aggregate `dy` over a window ending at each point. `function`: `DataAggregation.sum`, `.avg`, `.min`, `.max`, `.median`, `.std` (default `sum`). `window`: null = cumulative from start, N = last N elements. Updates `dy` and `fy` per point.

**IThresholdPoints** / **ThresholdPoints** — When `normalize` removes below-threshold points and uses `thresholdPoint`, the aggregate point’s `data` contains `ThresholdPoints(removed)` so you can access the original points via `point.of<IThresholdPoints>()?.thresholdPoints`.

```dart
final pipeline = DataPointPipeline().stack().normalize(total: 1.0);
final seriesA = pipeline.build(rawPointsA);
final seriesB = pipeline.build(rawPointsB);
```

For example, `stack(groupingStep: 1e-9)` groups `0.1 + 0.2` and `0.3` at the same x position.

---

## Widget options

**SparklinesChart**

- **charts** — List of `ISparklinesData` (e.g. `LineData`, `BarData`, `PieData`, `BetweenLineData`).
- **layout** — Default `IChartLayout` (e.g. `AbsoluteLayout()`, `RelativeLayout.full()`).
- **crop** — Default clip-to-bounds.
- **padding** — Global chart insets; defaults to `const ChartInsets()` (no insets).
- **width** / **height** — Fixed size; one can be null and filled by layout.
- **aspectRatio** — Used when both width and height are null.
- **animate** — Enable data-driven animation (default `true`).
- **animationDuration** — Default 300 ms.
- **animationCurve** — Default `Curves.easeInOut`.

Charts implement `ILerpTo` for smooth transitions when data changes.

---

## Extending

- **IDataPointStyle** + **IDataPointRenderer** — Custom point markers.
- **IChartRenderer** — Custom chart types.
- **ILineTypeData** + **ILineTypeRenderer** — Custom line path and stroke.
- **IChartLayout** — Custom coordinate systems; implement `resolve()` and `transform()`.
- **ILengthValue** — Custom visual units; implement `resolve(ILengthContext)`.

Custom `ISparklinesData` implementations must expose `ChartInsets get padding`, implement `Iterable<DataPoint>`, and report `supportsPointExtents`. Use `IterableMixin<DataPoint>` to implement iteration from an existing point list. Return `const ChartInsets()` and `false` to opt out of local insets and automatic point-extent fitting.
