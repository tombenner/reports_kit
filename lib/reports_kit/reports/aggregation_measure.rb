module ReportsKit
  module Reports
    class AggregationMeasure < AbstractMeasure
      attr_accessor :properties

      def initialize(properties)
        self.properties = properties.dup
      end

      def label
        name
      end

      def name
        properties[:name]
      end

      def aggregation
        properties[:aggregation]
      end

      def measures
        @measures ||= Reports::Measure.new_from_properties!(properties, context_record: nil)
      end

      def filters
        measures.map(&:filters).flatten
      end

      def primary_measure
        measures.first
      end

      def dimensions
        primary_measure.dimensions
      end

      def model_class
        primary_measure.model_class
      end
    end
  end
end
