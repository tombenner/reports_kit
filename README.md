ReportsKit
=====
[![Build Status](https://travis-ci.org/tombenner/reports_kit.svg?branch=master)](https://travis-ci.org/tombenner/reports_kit)

ReportsKit lets you easily create beautiful charts with customizable, interactive filters.

For interactive examples, see [reportskit.co](https://www.reportskit.co/).

---

[<img src="docs/images/demo.gif?raw=true" width="700" />](docs/images/demo.gif?raw=true)

[<img src="docs/images/demo_area.png?raw=true" width="425" />](docs/images/demo_area.png?raw=true)
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
[<img src="docs/images/demo_dashed_line.png?raw=true" width="425" />](docs/images/demo_dashed_line.png?raw=true)

[<img src="docs/images/demo_horizontal_stacked.png?raw=true" width="425" />](docs/images/demo_horizontal_stacked.png?raw=true)
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
[<img src="docs/images/demo_legend.png?raw=true" width="425" />](docs/images/demo_legend.png?raw=true)

[<img src="docs/images/demo_multiautocomplete.png?raw=true" width="425" />](docs/images/demo_multiautocomplete.png?raw=true)
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
[<img src="docs/images/demo_radar.png?raw=true" width="230" />](docs/images/demo_radar.png?raw=true)

---

1. **Quick setup** - Install ReportsKit and create your first chart in less than one minute using just ~5 lines of code.
1. **Simple chart configuration** - Create charts using your existing Rails models. ReportsKit examines the column types and associations to understand how to render the chart.
1. **Powerful results** - To see what ReportsKit can create with minimal code, see [reportskit.co](https://www.reportskit.co/).

Resources
---------

* [Installation](#installation)
* [Quick Start](#quick-start)
* [Examples](https://www.reportskit.co/)
* [Documentation](docs)

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

Quick Start
-----------

After installation, you can create your first chart with just a YAML file and a single line in any view.

Configure the chart in the YAML file:

`config/reports_kit/reports/my_users.yml`
```yaml
measure: user
dimensions:
- created_at
```

Then pass that filename to `render_report` in a view:

`app/views/users/index.html.haml`
```haml
= render_report 'my_users'
```

You're done! `render_report` will render the following chart:

[<img src="docs/images/users_by_created_at.png?raw=true" width="500" />](docs/images/users_by_created_at.png?raw=true)

### Form Controls

You can add a date range form control to the above chart with a single line, using one of ReportsKit's form helpers:

`app/views/users/index.html.haml`
```haml
= render_report 'my_users' do |f|
  = f.date_range :created_at
```

[<img src="docs/images/users_by_created_at_with_filter.png?raw=true" width="500" />](docs/images/users_by_created_at_with_filter.png?raw=true)

Many other form controls are available; see [Filters](docs/filters.md) for more.

### How It Works

In the Quick Start chart, `measure: user` tells ReportsKit to count the number of `User` records, and `dimensions: ['created_at']` tells it to group by the week of the `created_at` column. Since `created_at` is a `datetime` column, ReportsKit knows that it should group the counts by week (the granularity is configurable), sort them chronologically, and add in zeros for any missing weeks.

ReportsKit infers sane defaults from your ActiveRecord model configurations. If there was a `belongs_to :company` association on `User` and you used `dimensions: ['company']`, then ReportsKit would count users grouped by the `company_id` column and show company names on the x-axis.

If you need more customization (e.g. custom filters, custom dimensions, custom aggregation functions, custom orders, aggregations of aggregations, etc), ReportsKit is very flexible and powerful and supports all of these with a simple syntax. It lets you use SQL, too.

To learn how to use more of ReportsKit's features, check out the following resources:

* [Examples](https://www.reportskit.co/)
* [Documentation](docs)

Testing
-------

ReportsKit is tested against PostgreSQL and MySQL. If you'd like to submit a PR, please be sure to use [Appraisal](https://github.com/thoughtbot/appraisal) to test your changes in both contexts:

```bash
appraisal rspec
```

License
-------

ReportsKit is released under the MIT License. Please see the MIT-LICENSE file for details.
