module ReportsKit
  class BaseController < ActionController::Base
    # This is intentionally public to allow external code to access it
    def context_record
      context_record_method = ReportsKit.configuration.context_record_method
      return unless context_record_method
      instance_eval(&context_record_method)
    end
  end
end
