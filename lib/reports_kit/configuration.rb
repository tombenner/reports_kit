module ReportsKit
  class Configuration
    attr_accessor :context_params_method, :context_record_method, :first_day_of_week

    def initialize
      self.context_params_method = nil
      self.context_record_method = nil
      self.first_day_of_week = :sunday
    end
  end
end
