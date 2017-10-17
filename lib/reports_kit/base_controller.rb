module ReportsKit
  class BaseController < ActionController::Base
    include ReportsKit::NormalizedParams

    # This is intentionally public to allow external code to access it
    def context_record
      ReportsKit.configuration.context_record(self)
    end

    private

    def modify_context_params
      modify_context_params_method = ReportsKit.configuration.modify_context_params_method
      params[:context_params] = modify_context_params_method.call(params[:context_params], self) if modify_context_params_method
    end
  end
end
