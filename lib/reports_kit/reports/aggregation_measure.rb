module ReportsKit
  module Reports
    class AggregationMeasure
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

      def primary_measure
        Measure.new(properties[:measures][0])
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
