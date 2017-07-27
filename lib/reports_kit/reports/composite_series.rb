module ReportsKit
  module Reports
    class CompositeSeries < AbstractSeries
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

      def composite_operator
        properties[:composite_operator]
      end

      def limit
        properties[:limit]
      end

      def serieses
        @serieses ||= Reports::Series.new_from_properties!(properties, context_record: nil)
      end

      def filters
        serieses.map(&:filters).flatten
      end

      def primary_series
        serieses.first
      end

      def dimensions
        primary_series.dimensions
      end

      def model_class
        primary_series.model_class
      end
    end
  end
end
