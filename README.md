ReportsKit
=====
Beautiful, interactive charts for Ruby on Rails

Overview
--------
ReportsKit lets you easily create beautiful charts with customizable, interactive filters.

For interactive examples, see [reportskit.co](https://www.reportskit.co).

[<img src="docs/images/flights_with_filters.png?raw=true" width="500" />](docs/images/flights_with_filters.png?raw=true)

Installation
------------

In `Gemfile`:
```ruby
gem 'reports_kit'
```

In `app/assets/stylesheets/application.css.scss`:
```scss
*= require reports_kit/application
```

In `app/assets/javascripts/application.js`:
```js
//= require reports_kit/application
```

In `config/routes.rb`:
```ruby
Rails.application.routes.draw do
  mount ReportsKit::Engine, at: '/'
  # ...
end
```

Usage
-----
### Your First Chart

In any view, render a chart that shows the number of records of a model (e.g. `user`) created over time:

```haml
# app/views/users/index.html.haml
= render_report measure: 'user', dimensions: ['created_at']
```

Any model and datetime column can be used:

```haml
= render_report measure: 'blog_post', dimensions: ['published_at']
```

You can also configure your charts using YAML and then pass the filename to `render_report`:

`config/reports_kit/reports/my_users.yml`
```yaml
measure: user
dimensions:
- created_at
```

```haml
= render_report 'my_users'
```

### Measures

The measure is what is being counted (or aggregated). You can use any model for the measure.

For example, say we have a `Flight` model with a `flight_at` datetime column. We can chart the number of flights over time:

```yaml
measure: flight
dimensions:
- flight_at
```
[<img src="docs/images/flights_by_flight_at.png?raw=true" width="500" />](docs/images/flights_by_flight_at.png?raw=true)

### Dimensions

#### Overview

The dimension is what the measure is being grouped by. You can use datetime columns, integer columns, string columns, associations, or even define custom dimensions.

For example, the chart below groups by a `carrier` association on `Flight`

```yaml
measure: flight
dimensions:
- carrier
```
[<img src="docs/images/flights_by_carrier.png?raw=true" width="500" />](docs/images/flights_by_carrier.png?raw=true)

You can also use two dimensions:

```yaml
measure: flight
dimensions:
- carrier
- flight_at
```
[<img src="docs/images/flights_by_carrier_and_flight_at.png?raw=true" width="500" />](docs/images/flights_by_carrier_and_flight_at.png?raw=true)

Dimensions can be configured using a string:

```yaml
measure: flight
dimensions:
- carrier
```

Or, if you need to use options, you can configure them using a hash:

```yaml
measure: flight
dimensions:
- key: carrier
  limit: 5
```
#### Types

##### Association

```yaml
measure: flight
dimensions:
- carrier
```
[<img src="docs/images/flights_by_carrier.png?raw=true" width="500" />](docs/images/flights_by_carrier.png?raw=true)

##### Datetime Column

```yaml
measure: flight
dimensions:
- flight_at
```
[<img src="docs/images/flights_by_flight_at.png?raw=true" width="500" />](docs/images/flights_by_flight_at.png?raw=true)

##### Integer Column

```yaml
measure: flight
dimensions:
- delay
```
[<img src="docs/images/flights_by_delay.png?raw=true" width="500" />](docs/images/flights_by_delay.png?raw=true)

##### Custom

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
measure: flight
dimensions:
- hours_delayed
```
[<img src="docs/images/flights_by_hours_delayed.png?raw=true" width="500" />](docs/images/flights_by_hours_delayed.png?raw=true)

#### Options

##### `key` *String*

The dimension's identifier. You can use association names (e.g. `author`), column names (e.g. `created_at`), or the keys of custom dimensions (e.g. `my_dimension`).

##### `limit` *Integer*

The maximum number of dimension instances to include.

### Filters

#### Overview

A filter is like a `where`: it filters the results to only include results that match a condition. You can use datetime columns, integer columns, string columns, associations, or even define custom filters.

For example, if the `Flight` model has a `delay` column that's an integer, the chart below will show only flights that have a delay of greater than 15 minutes:

```yaml
measure:
  key: flight
  filters:
  - key: delay
    criteria:
      operator: '>'
      value: 15
dimensions:
- carrier
```
[<img src="docs/images/flights_with_configured_number.png?raw=true" width="500" />](docs/images/flights_with_configured_number.png?raw=true)

You can also create form controls that the user can use to filter the chart:

```yaml
measure:
  key: flight
  filters:
  - carrier
  - carrier_name
  - is_on_time
  - flight_at
dimensions:
- flight_at
- carrier
```

In `app/views/my_view.html.haml`:
```haml
= render_report 'filters' do
  .pull-right
    = f.date_range :flight_at
  = f.multi_autocomplete :carrier, scope: 'top', placeholder: 'Carrier...'
  = f.string_filter :carrier_name, placeholder: 'Carrier name (e.g. Airlines)...', style: 'width: 175px;'
  .checkbox
    = label_tag :is_on_time do
      = f.check_box :is_on_time
      On time
```
[<img src="docs/images/flights_with_filters.png?raw=true" width="500" />](docs/images/flights_with_filters.png?raw=true)

#### Types

##### Boolean

```yaml
measure:
  key: flight
  filters:
  - key: is_on_time
    criteria:
      operator: true
      value: 15
dimensions:
- carrier
```
[<img src="docs/images/flights_with_configured_boolean.png?raw=true" width="500" />](docs/images/flights_with_configured_boolean.png?raw=true)

##### Datetime

```yaml
measure:
  key: flight
  filters:
  - key: flight_at
    criteria:
      operator: between
      value: Oct 1, 2016 - Jan 1, 2017
dimensions:
- carrier
```
[<img src="docs/images/flights_with_configured_datetime.png?raw=true" width="500" />](docs/images/flights_with_configured_datetime.png?raw=true)

##### Number

```yaml
measure:
  key: flight
  filters:
  - key: delay
    criteria:
      operator: '>'
      value: 15
dimensions:
- carrier
```
[<img src="docs/images/flights_with_configured_number.png?raw=true" width="500" />](docs/images/flights_with_configured_number.png?raw=true)

##### String

```yaml
measure:
  key: flight
  filters:
  - key: carrier_name
    criteria:
      operator: contains
      value: airlines
dimensions:
- carrier
```
[<img src="docs/images/flights_with_configured_string.png?raw=true" width="500" />](docs/images/flights_with_configured_string.png?raw=true)


#### Form Controls

##### Check Box

```yaml
measure:
  key: flight
  filters:
  - is_on_time
dimensions:
- flight_at
- carrier
```
```haml
= render_report 'filter_check_box' do
  .checkbox
    = label_tag :is_on_time do
      = f.check_box :is_on_time
      On time
```
[<img src="docs/images/flights_with_check_box.png?raw=true" width="500" />](docs/images/flights_with_check_box.png?raw=true)

##### Date Range

```yaml
measure:
  key: flight
  filters:
  - flight_at
dimensions:
- flight_at
- carrier
```
```haml
= render_report 'filter_date_range' do
  = f.date_range :flight_at
```
[<img src="docs/images/flights_with_date_range.png?raw=true" width="500" />](docs/images/flights_with_date_range.png?raw=true)

##### Multi-Autocomplete

```yaml
measure:
  key: flight
  filters:
  - carrier
dimensions:
- flight_at
- carrier
```
```haml
= render_report 'filter_multi_autocomplete' do
  = f.multi_autocomplete :carrier, scope: 'top', placeholder: 'Carrier...'
```
[<img src="docs/images/flights_with_multi_autocomplete.png?raw=true" width="500" />](docs/images/flights_with_multi_autocomplete.png?raw=true)

##### String Filter

```yaml
measure:
  key: flight
  filters:
  - carrier_name
dimensions:
- flight_at
- carrier
```
```haml
= render_report 'filter_string' do
  = f.string_filter :carrier_name, placeholder: 'Carrier name (e.g. Airlines)...', style: 'width: 175px;'
```
[<img src="docs/images/flights_with_string_filter.png?raw=true" width="500" />](docs/images/flights_with_string_filter.png?raw=true)

License
-------

ReportsKit is released under the MIT License. Please see the MIT-LICENSE file for details.
