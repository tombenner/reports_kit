### Display Options

#### Overview

Charts are rendered using [Chart.js](http://www.chartjs.org/). You can configure your ReportsKit chart using any [Chart.js options](http://www.chartjs.org/docs/).

##### `type`

You can use any `type` value supported by Chart.js, including `bar`, `line`, `horizontalBar`, `radar`, and more.

Here's an example of a horizontal bar chart:

```yaml
measure:
  key: flight
  dimensions:
  - carrier
chart:
  type: horizontalBar
  options:
    scales:
      xAxes:
      - scaleLabel:
          display: true
          labelString: Flights
      yAxes:
      - scaleLabel:
          display: true
          labelString: Carrier
```
[<img src="images/horizontal_bar.png?raw=true" width="500" />](images/horizontal_bar.png?raw=true)

##### `options`

You can use any `options` that are supported by Chart.js.

Here's an example of a chart with Chart.js options:

```yaml
measure:
  key: flight
  dimensions:
  - origin_market
  - carrier
chart:
  type: horizontalBar
  options:
    scales:
      xAxes:
      - stacked: true
        scaleLabel:
          display: true
          labelString: Flights
      yAxes:
      - stacked: true
        scaleLabel:
          display: true
          labelString: Market
```
[<img src="images/chart_options.png?raw=true" width="500" />](images/chart_options.png?raw=true)

##### `datasets`

You can use any `datasets` options that are supported by Chart.js.

Here's an example of a chart with `datasets` options:

```yaml
measure:
  key: flight
  dimensions:
  - flight_at
  - key: carrier
    limit: 3
chart:
  type: line
  datasets:
    fill: false
    borderDash:
      - 5
      - 5
```
[<img src="images/dashed_line.png?raw=true" width="500" />](images/dashed_line.png?raw=true)
