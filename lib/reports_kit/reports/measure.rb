module ReportsKit
  module Reports
    class Measure
      attr_accessor :properties

      def initialize(properties)
        properties = { key: properties } if properties.is_a?(String)
        self.properties = properties
      end

      def key
        properties[:key]
      end

      def label
        key.titleize
      end

      def aggregate_function
        :count
      end

      def base_relation
        model_class
      end

      def model_class
        key.singularize.camelize.constantize
      end

      def filtered_relation
        base_relation
      end
    end
  end
end
