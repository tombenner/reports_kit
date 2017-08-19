module ReportsKit
  module Helper
    ACTION_KEYS_METHODS = {
      'export_csv' => :export_csv_element,
      'export_xls' => :export_xls_element
    }

    def render_report(report_params, context_params: {}, actions: %w(export_csv export_xls), js_report_class: 'Report', &block)
      report_params = { key: report_params } if report_params.is_a?(String)
      additional_params = { context_params: context_params, report_params: report_params }
      params.merge!(additional_params)
      properties = instance_eval(&ReportsKit.configuration.properties_method)
      properties = properties.deep_symbolize_keys
      builder = ReportsKit::ReportBuilder.new(properties, additional_params: additional_params)
      path = reports_kit.reports_kit_reports_path({ format: 'json' }.merge(additional_params))
      data = { properties: properties.slice(:format), path: path, report_class: js_report_class }
      content_tag :div, nil, class: 'reports_kit_report form-inline', data: data do
        elements = []
        if block_given?
          elements << form_tag(path, method: 'get', class: 'reports_kit_report_form') do
            capture(builder, &block)
          end
        end
        elements << content_tag(:div, nil, class: 'reports_kit_visualization')
        action_elements = generate_action_elements(actions, additional_params)
        if action_elements
          elements << content_tag(:div, nil, class: 'reports_kit_actions') do
            action_elements.map { |element| concat(element) }
          end
        end
        elements.join.html_safe
      end
    end

    private

    def report_key
      params[:report_params][:key]
    end

    def generate_action_elements(actions, additional_params)
      return if actions.blank?
      actions.map do |action|
        element_method = ACTION_KEYS_METHODS[action]
        raise ArgumentError.new("Invalid action: #{action}") unless element_method
        send(element_method, additional_params)
      end
    end

    def export_csv_element(additional_params)
      data = {
        role: 'reports_kit_export_button',
        path: reports_kit.reports_kit_reports_path({ format: 'csv' }.merge(additional_params))
      }
      link_to('Download CSV', '#', class: 'btn btn-primary', data: data)
    end

    def export_xls_element(additional_params)
      data = {
        role: 'reports_kit_export_button',
        path: reports_kit.reports_kit_reports_path({ format: 'xls' }.merge(additional_params))
      }
      link_to('Download Excel', '#', class: 'btn btn-primary', data: data)
    end
  end
end
