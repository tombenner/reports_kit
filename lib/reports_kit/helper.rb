module ReportsKit
  module Helper
    def render_report(properties, &block)
      builder = ReportsKit::ReportBuilder.new(properties)
      content_tag :div, nil, class: 'reports_kit_report', data: { properties: builder.properties, path: reports_kit_path } do
        if block_given?
          form_tag reports_kit_path, method: 'get', class: 'reports_kit_report_form form-inline' do
            capture(builder, &block)
          end
        end
      end
    end
  end
end
