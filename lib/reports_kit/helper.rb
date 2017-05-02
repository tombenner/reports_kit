module ReportsKit
  module Helper
    def render_report(properties, &block)
      content_tag :div, nil, class: 'reports_kit_report', data: { properties: properties, path: reports_kit_path } do
        if block_given?
          builder = ReportsKit::ReportBuilder.new(properties)
          form_tag reports_kit_path, method: 'get', class: 'form-inline' do
            capture(builder, &block)
          end
        end
      end
    end
  end
end
