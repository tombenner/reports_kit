module ReportsKit
  class BaseController < ActionController::Base
    # This is intentionally public to allow external code to access it
    def context_record
      ReportsKit.configuration.context_record(self)
    end
  end
end
