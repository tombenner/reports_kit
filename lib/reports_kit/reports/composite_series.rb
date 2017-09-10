module ReportsKit
  module Reports
    class CompositeSeries < AbstractSeries
      attr_accessor :properties, :context_record

      def initialize(properties, context_record:)
        self.properties = properties.dup
        self.context_record = context_record
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
        @serieses ||= Reports::Series.new_from_properties!(properties, context_record: context_record)
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
