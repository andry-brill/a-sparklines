# Sparklines

Feature-rich, highly optimized sparklines for Flutter. Line, bar, pie, and between-line charts with shared layouts, animation, and flexible styling.

**Requirements:** Dart `>=3.0.0 <4.0.0`, Flutter `>=3.10.0`.

---

## Installation


```yaml
dependencies:
  sparklines: ^1.0.0
```

---

## Example

```dart
import 'package:flutter/material.dart';
import 'package:sparklines/sparklines.dart';

SparklinesChart(
  width: 300,
  height: 120,
  layout: const RelativeLayout.full(),
  crop: true,
  charts: [
    LineData(
      points: [
        DataPoint.value(0, 10),
        DataPoint.value(1, 25),
        DataPoint.value(2, 15),
        DataPoint.value(3, 40),
      ],
      thickness: const ThicknessData(size: 2, color: Colors.blue),
      areaColor: Colors.blue.withOpacity(0.2),
    ),
  ],
)
```

---

## Core concepts

### Layouts

- **AbsoluteLayout** — Data coordinates map 1:1 to pixels; origin bottom-left, Y up.
- **RelativeLayout** — Data is scaled to explicit bounds. Use `RelativeLayout.normalized()` (0–1), `RelativeLayout.signed()` (-1–1), or `RelativeLayout.full()` (auto from data). Set `minX`/`maxX`/`minY`/`maxY` to `double.infinity` to derive from chart data. **Identical layout instances are resolved once and shared** across all charts using them.
- **RelativeDimension** — For `RelativeLayout`, use `relativeTo: RelativeDimension.width` or `RelativeDimension.height` so lengths (e.g. stroke width) scale with chart size; `none` uses absolute values.

### Rotation and origin

- **ChartRotation** — `d0`, `d90`, `d180`, `d270` (clockwise). For `d90`/`d270`, logical width/height are swapped so the chart fills the widget.
- **origin** — `Offset` applied before rotation; use to position charts.

### Crop and visibility

- **crop** — When `true`, rendering is clipped to chart bounds. Chart-level `crop` overrides the widget default.
- **visible** — Per-chart; when `false`, the chart is skipped.

### DataPoint

- **x** — X coordinate.
- **y** — Base Y (e.g. stacked base).
- **dy** — Delta from base; **fy = y + dy** is the value used for drawing.
- **style** — Optional `IDataPointStyle` (e.g. `CircleDataPointStyle`).
- **thickness** — Optional `ThicknessOverride` (size, color, gradient, align) for this point.

### Thickness (global and per-point)

- **ThicknessData** — `size`, `color`, optional `gradient` (overrides color), `align`: `ThicknessData.alignInside` (-1), `alignCenter` (0), `alignOutside` (1).
- **ThicknessOverride** on `DataPoint` — Same fields; overrides chart thickness for that point.

### Border and border radius

- **IChartBorder** — `border` (`ThicknessData?`), `borderRadius` (`double?`). Used by **BarData** and **PieData**.

### Area fill (line charts)

- **areaColor** / **areaGradient** — Fill below the line (from line down to base Y). Gradient takes precedence over color.

---

## Line charts

**LineData** — `points`, `thickness`, `areaColor`/`areaGradient`, `lineType`, `pointStyle`.

### Line types

- **LinearLineData** — Straight segments; optional `isStrokeCapRound`, `isStrokeJoinRound`.
- **SteppedLineData** — Step at fraction between points: `stepJumpAt` 0→prev, 1→next; constructors `.start()`, `.middle()`, `.end()`.
- **CurvedLineData** — Smooth curve; `smoothness` 0.0–1.0 (default 0.35).

---

## Between-line charts

**BetweenLineData** — Fills the area between two lines. `from`, `to` (both `LineData`), `areaColor`, `areaGradient`. Uses same layout; both lines share the same coordinate system.

---

## Bar charts

**BarData** — `bars` (`List<DataPoint>`; `fy` = top, `y` = base), `thickness`, `border`, `borderRadius`, `pointStyle`. Bars are drawn from `y` to `fy`; use **DataPointPipeline** for stacking.

---

## Pie charts

**PieData** — Each **DataPoint** is one arc: **x** = radius, **y** = start angle, **dy** = sweep (end = y + dy). Angles in radians. `thickness`, `space` (gap between slices), `border`, `borderRadius`, `pointStyle`. Bounds are computed from slice geometry.

---

## DataPoint pipeline

**DataPointPipeline** — Build transformed lists for stacking/normalization; reuse one pipeline for multiple series so shared state (e.g. stacking) is consistent.

- **stack()** — Stack points by x; each point’s `y` becomes the running sum at that x, `dy` stays the value.
- **normalize(low, high, mid?, threshold?)** — Scale values into [low, high]; optional `mid` for diverging; `threshold` repeatedly drops smallest segment until none below threshold.
- **normalize2pi(low, high, mid?, threshold?)** — Same with default range `[0, 2π]` for angles.

```dart
final pipeline = DataPointPipeline().stack().normalize();
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
- **IChartLayout** — Custom coordinate systems; implement `resolve()`, `pathTransform()`, `toScreenLength()`.
