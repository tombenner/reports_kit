module ReportsKit
  class Configuration
    attr_accessor :cache_duration, :cache_store,
      :context_params_method, :context_record_method, :first_day_of_week

    def initialize
      self.cache_duration = 5.minutes
      self.cache_store = nil
      self.context_params_method = nil
      self.context_record_method = nil
      self.first_day_of_week = :sunday
    end
  end
end
