module ReportsKit
  module NormalizedParams
    def report_params
      params[:report_params]
    end

    def context_params
      params[:context_params]
    end

    def report_key
      raise ArgumentError.new('Blank report_params') if report_params.blank?
      report_params[:key]
    end
  end
end
