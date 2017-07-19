module ReportsKit
  module Reports
    class Filter
      attr_accessor :properties

      def initialize(properties)
        properties = { key: properties } if properties.is_a?(String)
        raise ArgumentError.new("Filter properties must be a String or Hash, not a #{properties.class.name}: #{properties.inspect}") unless properties.is_a?(Hash)
        self.properties = properties.deep_symbolize_keys
      end

      def key
        properties[:key]
      end

      def label
        key.titleize
      end

      def normalized_properties
        properties
      end
    end
  end
end
