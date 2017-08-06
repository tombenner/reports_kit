module ReportsKit
  class ModelConfiguration
    attr_accessor :aggregations, :dimensions, :filters, :autocomplete_scopes

    def initialize
      self.aggregations = []
      self.dimensions = []
      self.filters = []
      self.autocomplete_scopes = []
    end

    def aggregation(key, expression, properties = {})
      aggregations << { key: key.to_s, expression: expression }.merge(properties).symbolize_keys
    end

    def dimension(key, properties)
      dimensions << { key: key.to_s }.merge(properties).symbolize_keys
    end

    def filter(key, type_key, properties)
      filters << { key: key.to_s, type_key: type_key }.merge(properties).symbolize_keys
    end

    def autocomplete_scope(*scopes)
      self.autocomplete_scopes += scopes.map(&:to_s)
    end
  end
end
