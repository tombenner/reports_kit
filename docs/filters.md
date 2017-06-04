### Filters

#### Overview

A filter is like a SQL `WHERE`: it filters the results to only include results that match a condition. You can use datetime columns, integer columns, string columns, associations, or even define custom filters.

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
[<img src="images/flights_with_configured_number.png?raw=true" width="500" />](images/flights_with_configured_number.png?raw=true)

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

In `app/views/my_view.html.haml`, you can use ReportsKit's form helpers to create the controls:
```haml
= render_report 'filters' do |f|
  .pull-right
    = f.date_range :flight_at
  = f.multi_autocomplete :carrier, scope: 'top', placeholder: 'Carrier...'
  = f.string_filter :carrier_name, placeholder: 'Carrier name (e.g. Airlines)...', style: 'width: 175px;'
  .checkbox
    = label_tag :is_on_time do
      = f.check_box :is_on_time
      On time
```
[<img src="images/flights_with_filters.png?raw=true" width="500" />](images/flights_with_filters.png?raw=true)

#### Types

##### Boolean

Boolean filters can be used on any `boolean` columns, or you can define your own boolean filter (see [Custom Filters](#custom-filters)).

```yaml
measure:
  key: flight
  filters:
  - key: is_on_time
    criteria:
      operator: true
dimensions:
- carrier
```
[<img src="images/flights_with_configured_boolean.png?raw=true" width="500" />](images/flights_with_configured_boolean.png?raw=true)

##### Datetime

Datetime filters can be used on any `datetime` or `timestamp` columns, or you can define your own datetime filter (see [Custom Filters](#custom-filters)).

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
[<img src="images/flights_with_configured_datetime.png?raw=true" width="500" />](images/flights_with_configured_datetime.png?raw=true)

##### Number

Number filters can be used on any `integer`, `float`, or `decimal` columns, or you can define your own number filter (see [Custom Filters](#custom-filters)).

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
[<img src="images/flights_with_configured_number.png?raw=true" width="500" />](images/flights_with_configured_number.png?raw=true)

##### String

String filters can be used on any `string` or `text` columns, or you can define your own number filter (see [Custom Filters](#custom-filters)).

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
[<img src="images/flights_with_configured_string.png?raw=true" width="500" />](images/flights_with_configured_string.png?raw=true)

##### Custom Filters

You can define custom filters in your model. For example, if `Flight` has a column named `delay` (an integer with a unit of minutes), then we can define a `was_delayed` dimension:

```ruby
class Flight < ApplicationRecord
  include ReportsKit::Model

  reports_kit do
    filter :was_delayed, :boolean, conditions: 'delay IS NOT NULL AND delay > 15'
  end
end
```

We can then use the `was_delayed` filter:

```yaml
measure:
  key: flight
  filters:
  - key: was_delayed
    criteria:
      operator: true
dimensions:
- carrier
```
[<img src="images/flights_by_hours_delayed.png?raw=true" width="500" />](images/flights_by_hours_delayed.png?raw=true)

#### Form Controls

Most charting libraries don't provide interactive form controls, but ReportsKit does. It makes it easy to add form controls to allow end users to modify charts.

##### Check Box

Check boxes can be used with filters that have a `boolean` type.

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
= render_report 'filter_check_box' do |f|
  .checkbox
    = label_tag :is_on_time do
      = f.check_box :is_on_time
      On time
```
[<img src="images/flights_with_check_box.png?raw=true" width="500" />](images/flights_with_check_box.png?raw=true)

##### Date Range

Date ranges can be used with filters that have a `datetime` type.

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
= render_report 'filter_date_range' do |f|
  = f.date_range :flight_at
```
[<img src="images/flights_with_date_range.png?raw=true" width="500" />](images/flights_with_date_range.png?raw=true)

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
= render_report 'filter_multi_autocomplete' do |f|
  = f.multi_autocomplete :carrier, scope: 'top', placeholder: 'Carrier...'
```
[<img src="images/flights_with_multi_autocomplete.png?raw=true" width="500" />](images/flights_with_multi_autocomplete.png?raw=true)

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
= render_report 'filter_string' do |f|
  = f.string_filter :carrier_name, placeholder: 'Carrier name (e.g. Airlines)...', style: 'width: 175px;'
```
[<img src="images/flights_with_string_filter.png?raw=true" width="500" />](images/flights_with_string_filter.png?raw=true)
