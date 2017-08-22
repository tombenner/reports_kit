module ReportsKit
  class ReportBuilder
    include ActionView::Helpers

    attr_accessor :report_params, :context_params, :additional_params, :actions, :js_report_class, :properties, :view_context, :block, :form_builder

    ACTION_KEYS_METHODS = {
      'export_csv' => :export_csv_button,
      'export_xls' => :export_xls_button
    }

    def initialize(report_params:, context_params: {}, actions: %w(export_csv export_xls), js_report_class: 'Report', properties:, view_context:, block: nil)
      self.report_params = report_params.is_a?(String) ? { key: report_params } : report_params
      self.context_params = context_params
      self.additional_params = { context_params: context_params, report_params: self.report_params }
      self.actions = actions
      self.js_report_class = js_report_class
      self.view_context = view_context
      self.block = block
      self.properties = properties#view_context.instance_eval(&ReportsKit.configuration.properties_method).deep_symbolize_keys
      self.form_builder = ReportsKit::FormBuilder.new(properties, additional_params: additional_params)
    end

    def render
      data = { properties: properties.slice(:format), path: reports_data_path, report_class: js_report_class }
      view_context.content_tag :div, nil, class: 'reports_kit_report form-inline', data: data do
        elements = []
        elements << view_context.capture(self, &block) if block
        elements << view_context.content_tag(:div, nil, class: 'reports_kit_visualization')
        elements << action_elements_container
        elements.compact.join.html_safe
      end
    end

    def form(&block)
      raise ArgumentError.new('No block given for ReportBuilder#form') unless block
      view_context.form_tag(reports_data_path, method: 'get', class: 'reports_kit_report_form') do
        view_context.capture(form_builder, &block)
      end
    end

    def export_csv_button(text='Download CSV', options = {}, &block)
      export_button(text, 'csv', options, &block)
    end

    def export_xls_button(text='Download Excel', options = {}, &block)
      export_button(text, 'xls', options, &block)
    end

    def export_button(text, format, options, &block)
      data = {
        role: 'reports_kit_export_button',
        path: view_context.reports_kit.reports_kit_reports_path({ format: format }.merge(additional_params))
      }
      options = { class: 'btn btn-primary', data: data }.merge(options)
      if block_given?
        view_context.link_to('#', options, &block)
      else
        view_context.link_to(text, '#', options)
      end
    end

    private

    def reports_data_path
      @reports_data_path ||= view_context.reports_kit.reports_kit_reports_path({ format: 'json' }.merge(additional_params))
    end

    def action_elements_container
      return if action_elements.blank?
      view_context.content_tag(:div, nil, class: 'reports_kit_actions') do
        action_elements.map { |element| view_context.concat(element) }
      end
    end

    def action_elements
      @action_elements ||= begin
        return if actions.blank?
        actions.map do |action|
          element_method = ACTION_KEYS_METHODS[action]
          raise ArgumentError.new("Invalid action: #{action}") unless element_method
          send(element_method)
        end.compact
      end
    end
  end
end
