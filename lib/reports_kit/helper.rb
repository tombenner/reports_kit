module ReportsKit
  module Helper
    def render_report(properties)
      content_tag :div, nil, class: 'reports_kit_report', data: { properties: properties, path: reports_kit_path }
    end
  end
end
