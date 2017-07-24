### Dimensions

#### Overview

The dimension is what the measure is being grouped by. You can use datetime columns, integer columns, string columns, associations, or even define custom dimensions.

For example, say you have a `Flight` model with a `belongs_to :carrier` association:

```ruby
class Flight < ActiveRecord::Base
  belongs_to :carrier
end
```

You can then use `dimensions: ['carrier']` to count the number of Flights per Carrier:

```yaml
measure:
  key: flight
  dimensions:
  - carrier
```
[<img src="images/flights_by_carrier.png?raw=true" width="500" />](images/flights_by_carrier.png?raw=true)

You can also use two dimensions:

```yaml
measure:
  key: flight
  dimensions:
  - carrier
  - flight_at
```
[<img src="images/flights_by_carrier_and_flight_at.png?raw=true" width="500" />](images/flights_by_carrier_and_flight_at.png?raw=true)

Dimensions can be configured using a string (`carrier`):

```yaml
measure:
  key: flight
  dimensions:
  - carrier
```

Or, if you need to use options, you can configure them using a hash:

```yaml
measure:
  key: flight
  dimensions:
  - key: carrier
    limit: 5
```
#### Types

##### Association

```yaml
measure:
  key: flight
  dimensions:
  - carrier
```
[<img src="images/flights_by_carrier.png?raw=true" width="500" />](images/flights_by_carrier.png?raw=true)

##### Datetime Column

```yaml
measure:
  key: flight
  dimensions:
  - flight_at
```
[<img src="images/flights_by_flight_at.png?raw=true" width="500" />](images/flights_by_flight_at.png?raw=true)

##### Integer Column

```yaml
measure:
  key: flight
  dimensions:
  - delay
```
[<img src="images/flights_by_delay.png?raw=true" width="500" />](images/flights_by_delay.png?raw=true)

##### Custom Dimensions

You can define custom dimensions in your model. For example, if `Flight` has a column named `delay` (in minutes), we can define a `hours_delayed` dimension:

```ruby
class Flight < ApplicationRecord
  include ReportsKit::Model

  reports_kit do
    dimension :hours_delayed, group: 'GREATEST(ROUND(flights.delay::float/60), 0)'
  end
end
```

We can then use the `hours_delayed` dimension:

```yaml
measure:
  key: flight
  dimensions:
  - hours_delayed
```
[<img src="images/flights_by_hours_delayed.png?raw=true" width="500" />](images/flights_by_hours_delayed.png?raw=true)

#### Options

##### `key` *String*

The dimension's identifier. You can use association names (e.g. `author`), column names (e.g. `created_at`), or the keys of custom dimensions (e.g. `my_dimension`).

##### `limit` *Integer*

The maximum number of dimension instances to include. For example, if you set `limit: 5` and have one dimension, then the x-axis will only show 5 items.
