ReportsKit
=====
ReportsKit lets you easily create beautiful charts with customizable, interactive filters.

Add powerful reporting to your Rails app in minutes, not months!

For interactive examples, see [reportskit.co](https://www.reportskit.co/).

---

[<img src="docs/images/demo.gif?raw=true" width="500" />](docs/images/demo.gif?raw=true)
[<img src="docs/images/demo_area.png?raw=true" width="500" />](docs/images/demo_area.png?raw=true)
[<img src="docs/images/demo_dashed_line.png?raw=true" width="500" />](docs/images/demo_dashed_line.png?raw=true)
[<img src="docs/images/demo_horizontal_stacked.png?raw=true" width="500" />](docs/images/demo_horizontal_stacked.png?raw=true)
[<img src="docs/images/demo_legend.png?raw=true" width="500" />](docs/images/demo_legend.png?raw=true)
[<img src="docs/images/demo_multiautocomplete.png?raw=true" width="500" />](docs/images/demo_multiautocomplete.png?raw=true)
[<img src="docs/images/demo_radar.png?raw=true" width="250" />](docs/images/demo_radar.png?raw=true)

---

1. **Quick setup** - Install ReportsKit and create your first chart in less than one minute using just ~5 lines of code.
1. **Simple chart configuration** - Create charts using your existing Rails models. ReportsKit examines the column types and associations to understand how to render the chart.
1. **Powerful results** - To see what ReportsKit can create with minimal code, see [reportskit.co](https://www.reportskit.co/).

Resources
---------

* [Installation](#installation)
* [Quick Start](#quick-start)
* [Examples](https://www.reportskit.co/)
* [Documentation](documentation)

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

After installation, you can create your first chart with a single line!

In any view, create a chart that shows the number of records of a model (e.g. `user`) created over time:

`app/views/users/index.html.haml`
```haml
= render_report measure: 'user', dimensions: ['created_at']
```

You're done! `render_report` will render the following chart:

[<img src="docs/images/users_by_created_at.png?raw=true" width="500" />](docs/images/users_by_created_at.png?raw=true)

Instead of passing a hash to `render_report`, you can alternatively configure your charts using YAML and then pass the filename to `render_report`:

`config/reports_kit/reports/my_users.yml`
```yaml
measure: user
dimensions:
- created_at
```

`app/views/users/index.html.haml`
```haml
= render_report 'my_users'
```

The YAML approach is more maintainable and readable, so we'll use it in the rest of the documentation.

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

In the Quick Start chart, `measure: 'user'` tells ReportsKit to count the number of `User` records, and `dimensions: ['created_at']` tells it to group by the week of the `created_at` column. Since `created_at` is a `datetime` column, ReportsKit knows that it should sort the results chronologically.

To learn how to use more of ReportsKit's features, check out the following resources:

* [Examples](https://www.reportskit.co/)
* [Documentation](documentation)

License
-------

ReportsKit is released under the MIT License. Please see the MIT-LICENSE file for details.
