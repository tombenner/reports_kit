module ReportsKit
  module Reports
    class PropertiesToFilter
      attr_accessor :properties, :context_record

      def initialize(properties, context_record: nil)
        self.properties = properties
        self.context_record = context_record
      end

      def perform(filter_key)
        filter_key = filter_key.to_s
        filter = filters.find { |f| f.key == filter_key }
        raise ArgumentError.new("A filter with key '#{filter_key}' is not configured in this report") unless filter
        filter
      end

      private

      def filters
        @filters ||= ui_filters + series_filters
      end

      def series_filters
        serieses.map(&:filters).flatten
      end

      def ui_filters
        return [] if properties[:ui_filters].blank?
        properties[:ui_filters].map do |ui_filter_properties|
          Reports::Filter.new(ui_filter_properties)
        end
      end

      def serieses
        Reports::Series.new_from_properties!(properties, context_record: context_record)
      end
    end
  end
end
