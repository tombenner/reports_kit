module ReportsKit
  module Helper
    def render_report(report_params, context_params: {}, actions: %w(export_csv export_xls), js_report_class: 'Report', &block)
      report_params = { key: report_params } if report_params.is_a?(String)
      params.merge!(context_params: context_params, report_params: report_params)
      properties = instance_eval(&ReportsKit.configuration.properties_method).deep_symbolize_keys
      builder = ReportBuilder.new(
        report_params: report_params,
        context_params: context_params,
        actions: actions,
        js_report_class: js_report_class,
        properties: properties,
        view_context: self,
        block: block
      )
      capture do
        capture(builder, &block) if block
        builder.render
      end
    end

    def context_params
      params[:context_params]
    end

    def report_params
      params[:report_params]
    end

    def report_key
      report_params[:key]
    end
  end
end
