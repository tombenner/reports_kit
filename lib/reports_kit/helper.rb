module ReportsKit
  module Helper
    ACTION_KEYS_METHODS = {
      'export_csv' => :export_csv_element,
      'export_xls' => :export_xls_element
    }

    def render_report(properties, &block)
      raise ArgumentError.new('`properties` must be a Hash or String') if properties.blank?
      if properties.is_a?(String)
        path = Rails.root.join('config', 'reports_kit', 'reports', "#{properties}.yml")
        properties = YAML.load_file(path)
      end
      builder = ReportsKit::ReportBuilder.new(properties)
      path = reports_kit.reports_kit_reports_path({ format: 'json' }.merge(additional_params))
      content_tag :div, nil, class: 'reports_kit_report form-inline', data: { properties: builder.properties, path: path } do
        elements = []
        if block_given?
          elements << form_tag(path, method: 'get', class: 'reports_kit_report_form') do
            capture(builder, &block)
          end
        end
        elements << content_tag(:div, nil, class: 'reports_kit_visualization')
        action_elements = action_elements_for_properties(properties)
        if action_elements
          elements << content_tag(:div, nil, class: 'reports_kit_actions') do
            action_elements.map { |element| concat(element) }
          end
        end
        elements.join.html_safe
      end
    end

    private

    def additional_params
      @additional_params ||= begin
        context_params_method = ReportsKit.configuration.context_params_method
        return {} unless context_params_method
        context_params = instance_eval(&context_params_method)
        { context_params: context_params }
      end
    end

    def action_elements_for_properties(properties)
      return if properties['actions'].blank?
      properties['actions'].map do |action|
        element_method = ACTION_KEYS_METHODS[action]
        raise ArgumentError.new("Invalid action: #{action}") unless element_method
        send(element_method)
      end
    end

    def export_csv_element
      data = {
        role: 'reports_kit_export_button',
        path: reports_kit.reports_kit_reports_path({ format: 'csv' }.merge(additional_params))
      }
      link_to('Download CSV', '#', class: 'btn btn-primary', data: data)
    end

    def export_xls_element
      data = {
        role: 'reports_kit_export_button',
        path: reports_kit.reports_kit_reports_path({ format: 'xls' }.merge(additional_params))
      }
      link_to('Download Excel', '#', class: 'btn btn-primary', data: data)
    end
  end
end
