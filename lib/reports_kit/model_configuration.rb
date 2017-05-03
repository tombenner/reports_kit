module ReportsKit
  class ModelConfiguration
    attr_accessor :dimensions, :filters

    def initialize
      self.dimensions = []
      self.filters = []
    end

    def dimension(key, properties)
      self.dimensions << { key: key.to_s }.merge(properties).symbolize_keys
    end

    def filter(key, properties)
      self.filters << { key: key.to_s }.merge(properties).symbolize_keys
    end
  end
end
