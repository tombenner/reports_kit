module ReportsKit
  class Configuration
    attr_accessor :cache_duration, :cache_store, :context_record_method, :custom_methods, :default_dimension_limit,
      :default_properties, :first_day_of_week, :properties_method, :report_filename_method, :use_concurrent_queries

    def initialize
      self.cache_duration = 5.minutes
      self.cache_store = nil
      self.context_record_method = nil
      self.custom_methods = {}
      self.default_dimension_limit = 30
      self.default_properties = nil
      self.first_day_of_week = :sunday
      self.properties_method = nil
      self.report_filename_method = nil
      self.use_concurrent_queries = false
    end

    def custom_method(method_name)
      return if method_name.blank?
      method = evaluated_custom_methods[method_name.to_sym]
      raise ArgumentError.new("A method named '#{method_name}' is not defined") unless method
      method
    end

    def evaluated_custom_methods
      return custom_methods if custom_methods.is_a?(Hash)
      return custom_methods.call if custom_methods.is_a?(Proc)
      raise ArgumentError.new("Invalid type for custom_methods configuration: #{custom_methods.class}")
    end
  end
end
