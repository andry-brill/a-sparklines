## 3.1.0

* **LineData**
  * Added `LineData.scatter(points: ...)` for marker-only x/y plots without connected lines or area fills.
  * Added `ScatterLineData`; scatter rendering is selected through `lineType` and can be changed with `copyWith(lineType: ...)`.
  * Single-point line and scatter data now render their point marker.
* **Breaking: custom line types**
  * `ILineTypeData` now requires `drawLine` and `minPoints` so renderers can determine whether and when to draw connected geometry.
* **DataPoint and DataPointPipeline**
  * Added `DataPoint.z` as an interpolated third dimension that does not affect layout bounds.
  * Added direct `Object?` point keys for selecting pipeline transformations; keys retain the source value at `t <= 0` and adopt the destination value afterward during interpolation.
  * Removed `IDataPointMeta` and replaced `DataPointMeta` with the value-based `DataPointKey`, retaining its `id`, string `key`, and `label` fields.
  * Added `rescaleZ()` with shared automatic bounds, optional clamping, and target-midpoint handling for equal z values.
  * Added `scatterZ()` with optional key/predicate filtering and z-interpolated `StylesInterval`/`ExtentsInterval` metadata.
  * Added optional z ordering to `sort()`.
* **Visual lengths**
  * Added `Vmin` and `Vmax` for percentages of the shorter and longer logical viewport dimensions.
* **Chart insets and point fitting**
  * Added reusable `ChartInsets` with optional `left`, `top`, `right`, and `bottom` `ILengthValue`s for global widget padding and local per-chart padding.
  * `ChartInsets` implements `IDataPointExtent` and can be stored in `DataPoint.data` for automatic, position-aware visual overflow fitting around `(x, fy)`.
  * Global padding, local padding, and point overflow are combined once from the preliminary transform without changing source data or layout bounds.
  * Charts sharing a layout receive one aligned inset transform; over-constrained axes collapse to the weighted position between their opposing insets.
* **Seat maps**
  * Added `SeatKey` with an optional database/display label and value identity based on area, row, and column.
  * Added `SeatSelector` with OR-set label, row, column, and nullable-area filters plus OR-of-AND tag groups.
  * Added deferred `SeatsBuilder` actions for fluent row and column geometry with labels, horizontal and vertical gaps, skipped slots, z values, tags, areas, and point metadata.
  * Added nestable `record()`/`repeat()` blocks and reusable `saveRecord()` action templates for replaying seat-layout sequences during `build()`.
  * Added `saveState()`, `saveOnlyState()`, and `restoreState()` for deferred gap, area, tag, and data snapshots.
  * Added `ISeatLabelBuilder`, default `NullLabels`, and exact-consumption `ListLabels` with end-of-build validation.
  * Added `DataPointPipeline.seats()` for fixed style and optional extent decoration using selectors, predicates, and exact seat keys.
* **Breaking: custom chart data**
  * Replaced `ChartPadding` with `ChartInsets` without a compatibility alias.
  * `IDataPointExtent` now extends `IDataPointData` so custom extents can be stored directly in point metadata.
  * `ISparklinesData` now implements `Iterable<DataPoint>` and requires `padding` and `supportsPointExtents`.
  * `BetweenLineData` iterates its `from` points followed by its `to` points but disables point-extent fitting.

## 3.0.1

* **DataPointPipeline**
  * Added optional `groupingStep` to `stack()`. When provided, nearby x values are grouped into rounded buckets of that size; the default remains exact x matching.

## 3.0.0

* **Breaking: unit-aware visual lengths**
  * `ThicknessData.size`, `ThicknessOverride.size`, marker radius, and chart/data-point border radius now use `ILengthValue`.
  * Added `Px`, `Vw`, `Vh`, `Dx`, and `Dy`; viewport units follow CSS percentage semantics (`Vw(1)` is 1%).
  * Added deferred cross-unit interpolation and support for custom length implementations through `ILengthContext`.
* **Breaking: simplified layouts**
  * Removed `RelativeDimension`, `RelativeLayout.relativeTo`, and `IChartLayout.transformScalar()`.
  * `ChartTransform` no longer accepts an `IChartLayout`; it resolves lengths from its dimensions and path matrix.
  * Layouts now transform plot coordinates only; each visual value owns its sizing policy.
  * Pie auto-bounds are derived from data geometry and no longer include visual thickness, borders, corners, or markers.

### Migration

| 2.x | 3.0 |
| --- | --- |
| `ThicknessData(size: 2)` | `ThicknessData(size: Px(2))` |
| `CircleDataPointStyle(radius: 4, ...)` | `CircleDataPointStyle(radius: Px(4), ...)` |
| `borderRadius: 4` | `borderRadius: Px(4)` |
| `relativeTo: RelativeDimension.width` with a scalar `0.1` | Remove `relativeTo`; use `Dx(0.1)` on that visual property |
| `relativeTo: RelativeDimension.height` with a scalar `0.1` | Remove `relativeTo`; use `Dy(0.1)` on that visual property |
| Custom `IChartLayout.transformScalar()` | Remove it; custom units implement `ILengthValue.resolve()` |
| `ChartTransform(layout: layout, dimensions: d, pathTransform: m)` | `ChartTransform(dimensions: d, pathTransform: m)` |

## 2.2.6

- Improved `pubspec.yaml`
- Fixed lint warnings

## 2.2.5

* **DataPointPipeline**
  * **stack({ offset?, spacing? })** — Added `offset` to set the initial stacked base for each `x` (default 0.0).

## 2.2.4

* **DataPointPipeline**
  * **sort({ x?, y?, fy? })** — Sort input by x, y, and/or fy. Each flag: `true` = ascending, `false` = descending. If all null, sorts by x ascending.
  * **aggregate({ function?, window? })** — Aggregate `dy` over a window ending at each point. `DataAggregation`: `sum`, `avg`, `min`, `max`, `median`, `std`. `window`: null = cumulative from start, N = last N elements. Updates `dy` and `fy` per point.

## 2.2.3

* **rescale** — Rescale now transforms full intervals `[y..fy]` from source to target bounds; both `y` and `fy` are mapped, and `dy` is set to `fy - y`.  Non-finite `currentMin`/`currentMax` are derived from input interval bounds.

## 2.2.2

* Added `rescale` to `DataPointPipeline`

## 2.2.1

* Added `trailingSpacing` and `spacingDeg` to `DataPointPipeline`

## 2.2.0

* Made the radius and thickness properties in `PieData` uniform by default, consistent with `LineData` and `BarData`
  * Use `RelativeLayout(.., relativeTo: RelativeDimension.width)` to make them relative again

## 2.1.4

* Fixed `CircleArcBuilder` for angles >= 2 * pi

## 2.1.3

* Fixed `LayoutData` min/max assert

## 2.1.2

* Fixed drawing DataPoints in `CircleDataPointRenderer`

## 2.1.1

* Added **ChartFlip** — `none`, `vertically`, `horizontally`, `both`. Flip charts around axes; available on all chart data types via `ISparklinesData.flip`.

## 2.1.0

* Renaming
  * LineChart.points => line
  * PieChart.points => pies
* Added `IDataPointBorder` and `DataPointBorder`
* Refactoring

## 2.0.0

* `DataPoint`
  * added `IDataPointData`
    * `DataPointMeta`
    * `ThresholdPoints`
  * migrated everything to `DataPoint.data`
* `DataPointPipeline`
  * refactored
  * tests

## 1.1.0

* `DataPoint`
  * added `dx`
  * removed `getYorDy`
* `DataPointPipeline`
  * fixes and tests
* `PieData`
  * renamed `space` to `dx`
  * added `padAngle`

## 1.0.0

* Initial release
