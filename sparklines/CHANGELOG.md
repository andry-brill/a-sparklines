
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