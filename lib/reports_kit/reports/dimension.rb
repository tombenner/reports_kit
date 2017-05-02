module ReportsKit
  module Reports
    class Dimension
      attr_accessor :properties, :measure

      def initialize(properties, measure: measure)
        properties = { key: properties } if properties.is_a?(String)
        self.properties = properties
        self.measure = measure
      end

      def key
        properties[:key]
      end

      def group_expression
        reflection.foreign_key
      end

      def group_joins
        nil
      end

      def should_be_sorted_by_count?
        !instance_class.is_a?(Time)
      end

      def instance_class
        reflection.class_name.constantize
      end

      private

      def reflection
        measure.model_class.reflect_on_association(key)
      end
    end
  end
end
