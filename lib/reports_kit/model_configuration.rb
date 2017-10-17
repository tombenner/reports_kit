module ReportsKit
  class ModelConfiguration
    attr_accessor :aggregations, :contextual_filters, :dimensions, :filters

    def initialize
      self.aggregations = []
      self.contextual_filters = []
      self.dimensions = []
      self.filters = []
    end

    def aggregation(key, expression, properties = {})
      aggregations << { key: key.to_s, expression: expression }.merge(properties).symbolize_keys
    end

    def contextual_filter(key, method)
      contextual_filters << { key: key, method: method }
    end

    def dimension(key, properties)
      dimensions << { key: key.to_s }.merge(properties).symbolize_keys
    end

    def filter(key, type_key, properties)
      filters << { key: key.to_s, type_key: type_key }.merge(properties).symbolize_keys
    end
  end
end
