# Sparklines

[![Tests](https://github.com/andry-brill/a-sparklines/actions/workflows/test.yml/badge.svg)](https://github.com/andry-brill/a-sparklines/actions/workflows/test.yml)

Feature-rich, highly optimized sparklines for Flutter. Line, bar, pie, and between-line charts with shared layouts, animation, and flexible styling.

![App Screenshot](https://raw.githubusercontent.com/andry-brill/a-sparklines/main/sparklines/example/web/example.png)

---

## Core concepts

### Layouts

- **AbsoluteLayout** — Data coordinates map 1:1 to pixels; origin bottom-left, Y up.
- **RelativeLayout** — Data is scaled to explicit bounds. Use `RelativeLayout.normalized()` (0–1), `RelativeLayout.signed()` (-1–1), or `RelativeLayout.full()` (auto from data). Set `minX`/`maxX`/`minY`/`maxY` to `double.infinity` or `double.negativeInfinity` to derive from chart data. **Identical layout instances are resolved once and shared** across all charts using them.
- **RelativeDimension** — For `RelativeLayout`, use `relativeTo: RelativeDimension.width` or `RelativeDimension.height` so lengths (e.g. stroke width) scale with chart size; `none` uses absolute values.

### Rotation, flip, and origin

- **ChartRotation** — `d0`, `d90`, `d180`, `d270` (clockwise). For `d90`/`d270`, logical width/height are swapped so the chart fills the widget.
- **ChartFlip** — `none`, `vertically`, `horizontally`, `both`. Flip charts around axes; applied after rotation.
- **origin** — `Offset` applied before rotation; use to position charts.

### Crop and visibility

- **crop** — When `true`, rendering is clipped to chart bounds. Chart-level `crop` overrides the widget default.
- **visible** — Per-chart; when `false`, the chart is skipped.

### DataPoint

- **x** — X coordinate.
- **y** — Base Y (e.g. stacked base).
- **dy** — Delta from base; **fy = y + dy** is the value used for drawing.
- **data** — Extensible `Map<Type, IDataPointData?>` for per-point metadata. Keys are type tokens; values implement `IDataPointData` (supports `lerpTo` for animation). Use `point.of<M>()` for type-safe access.

**Common data entries** (via extension getters or `of<M>()`):

- **style** — `IDataPointStyle?` (e.g. `CircleDataPointStyle`) for point markers.
- **thickness** — `IThicknessOverride?` (size, color, gradient, align) to override chart thickness for this point.
- **pieOffset** — `IPieOffset?` for pie slice offset.
- **DataPointMeta** — `id`, `key`, `label` for tooltips or identification.

### Thickness (global and per-point)

- **ThicknessData** — `size`, `color`, optional `gradient` (overrides color), `align`: `ThicknessData.alignInside` (-1), `alignCenter` (0), `alignOutside` (1).
- **ThicknessOverride** on `DataPoint` — Same fields; overrides chart thickness for that point.

### Border and border radius

- **IChartBorder** — `border` (`ThicknessData?`), `borderRadius` (`double?`). Used by **BarData** and **PieData**.

### Area fill (line charts)

- **areaColor** / **areaGradient** — Fill below the line (from line down to base Y). Gradient takes precedence over color.
- **areaFillType** — Optional `PathFillType` for the fill.

---

## Line charts

**LineData** — `line`, `thickness`, `areaColor`/`areaGradient`, `areaFillType`, `lineType`, `pointStyle`.

### Line types

- **LinearLineData** — Straight segments; optional `isStrokeCapRound`, `isStrokeJoinRound`.
- **SteppedLineData** — Step at fraction between points: `stepJumpAt` 0→prev, 1→next; constructors `.start()`, `.middle()`, `.end()`.
- **CurvedLineData** — Smooth curve; `smoothness` 0.0–1.0 (default 0.35).

## Between-line charts

**BetweenLineData** — Fills the area between two lines. `from`, `to` (both `LineData`), `areaColor`, `areaGradient`, `areaFillType`. Uses same layout; both lines share the same coordinate system.

## Bar charts

**BarData** — `bars` (`List<DataPoint>`; `fy` = top, `y` = base), `thickness`, `border`, `borderRadius`, `pointStyle`. Bars are drawn from `y` to `fy`; use **DataPointPipeline** for stacking.

## Pie charts

**PieData** — Each **DataPoint** is one arc: **x** = radius, **y** = start angle, **dy** = sweep (end = y + dy). Angles in radians. `thickness`, `padAngle` (gap between slices), `pieOffset`, `border`, `borderRadius`, `pointStyle`. Bounds are computed from slice geometry.

---

## DataPoint pipeline

**DataPointPipeline** — Build transformed lists for stacking/normalization; reuse one pipeline for multiple series so shared state (e.g. stacking) is consistent.

- **stack({ spacing })** — Stack points by x; each point’s `y` becomes the running sum at that x, `dy` stays the value. Optional `spacing` adds gap between stacked segments.
- **normalize({ total, threshold?, spacing?, trailingSpacing?, thresholdPoint? })** — Scale `dy` so sum of `abs(dy)` equals `total` (default 1.0). `threshold` repeatedly drops smallest segment until none below threshold; `thresholdPoint` receives accumulated dy of removed points. `spacing` reserves gap between segments; `trailingSpacing` adds one more spacing (useful for full pies).
- **normalize2pi({ total, threshold?, spacing?, spacingDeg?, trailingSpacing?, thresholdPoint? })** — Same as `normalize` with default `total` 2π for angles. `spacingDeg` is spacing in degrees (converted to radians); `trailingSpacing` defaults to true when `total >= 2` or `total <= -2`.
- **rescale({ currentMin?, currentMax?, targetMin, targetMax })** — Linearly rescale intervals `[DataPoint.y..DataPoint.fy]` from `[currentMin..currentMax]` to `[targetMin..targetMax]` (default 0–1). Both `y` and `fy` are transformed; `dy` is recalculated as `fy - y`. If `currentMin` or `currentMax` are not finite, they are computed from input interval bounds.
- **sort({ x?, y?, fy? })** — Sort input by x, y, and/or fy. Each: `true` = ascending, `false` = descending. If all null, sorts by x ascending.
- **aggregate({ function, window? })** — Aggregate `dy` over a window ending at each point. `function`: `DataAggregation.sum`, `.avg`, `.min`, `.max`, `.median`, `.std` (default `sum`). `window`: null = cumulative from start, N = last N elements. Updates `dy` and `fy` per point.

**IThresholdPoints** / **ThresholdPoints** — When `normalize` removes below-threshold points and uses `thresholdPoint`, the aggregate point’s `data` contains `ThresholdPoints(removed)` so you can access the original points via `point.of<IThresholdPoints>()?.thresholdPoints`.

```dart
final pipeline = DataPointPipeline().stack().normalize(total: 1.0);
final seriesA = pipeline.build(rawPointsA);
final seriesB = pipeline.build(rawPointsB);
```

---

## Widget options

**SparklinesChart**

- **charts** — List of `ISparklinesData` (e.g. `LineData`, `BarData`, `PieData`, `BetweenLineData`).
- **layout** — Default `IChartLayout` (e.g. `AbsoluteLayout()`, `RelativeLayout.full()`).
- **crop** — Default clip-to-bounds.
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
- **IChartLayout** — Custom coordinate systems; implement `resolve()`, `transform()`, `transformScalar()`.
