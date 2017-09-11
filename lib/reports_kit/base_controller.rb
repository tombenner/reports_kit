module ReportsKit
  class BaseController < ActionController::Base
    include ReportsKit::NormalizedParams

    # This is intentionally public to allow external code to access it
    def context_record
      ReportsKit.configuration.context_record(self)
    end
  end
end
