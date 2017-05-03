module ReportsKit
  module Reports
    class Filter
      CONFIGURATION_STRATEGIES_FILTER_TYPE_CLASSES = {
        association: Reports::FilterTypes::Records,
        model: nil,
        time: FilterTypes::Datetime
      }

      attr_accessor :properties, :measure, :configuration

      delegate :configuration_strategy, :instance_class, to: :configuration

      def initialize(properties, measure:)
        self.configuration = InferrableConfiguration.new(self, :filters)
        self.measure = measure

        properties = { key: properties } if properties.is_a?(String)
        self.properties = properties.deep_symbolize_keys
      end

      def key
        properties[:key]
      end

      def label
        key.titleize
      end

      def type_klass
        CONFIGURATION_STRATEGIES_FILTER_TYPE_CLASSES[configuration_strategy] || raise(ArgumentError.new('Invalid configuration'))
      end

      def apply(relation)
        filter_type = type_klass.new(relation, properties)
        filter_type.apply_filter
      end
    end
  end
end
