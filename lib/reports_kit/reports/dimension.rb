module ReportsKit
  module Reports
    class Dimension
      attr_accessor :properties

      def initialize(properties)
        raise ArgumentError.new('Blank properties') if properties.blank?
        properties = { key: properties } if properties.is_a?(String)
        raise ArgumentError.new("Dimension properties must be a String or Hash, not a #{properties.class.name}: #{properties.inspect}") unless properties.is_a?(Hash)
        properties = properties.deep_symbolize_keys
        self.properties = properties
      end

      def key
        properties[:key]
      end

      def label
        key.titleize
      end
    end
  end
end
