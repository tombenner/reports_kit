module ReportsKit
  module Reports
    class Measure
      attr_accessor :properties, :dimensions, :filters, :context_record

      def initialize(properties, context_record: nil)
        properties = properties.dup
        properties = { key: properties } if properties.is_a?(String)
        raise ArgumentError.new("Measure properties must be a String or Hash, not a #{properties.class.name}: #{properties.inspect}") unless properties.is_a?(Hash)
        properties = properties.deep_symbolize_keys

        dimension_hashes = properties[:dimensions] || []
        dimension_hashes = dimension_hashes.values if dimension_hashes.is_a?(Hash) && dimension_hashes.key?(:'0')
        filter_hashes = properties[:filters] || []
        filter_hashes = filter_hashes.values if filter_hashes.is_a?(Hash) && filter_hashes.key?(:'0')

        self.properties = properties
        self.dimensions = dimension_hashes.map { |dimension_hash| DimensionWithMeasure.new(dimension: Dimension.new(dimension_hash), measure: self) }
        self.filters = filter_hashes.map { |filter_hash| FilterWithMeasure.new(filter: Filter.new(filter_hash), measure: self) }
        self.context_record = context_record
      end

      def key
        properties[:key].underscore
      end

      def label
        properties[:name].presence || key.pluralize.titleize
      end

      def relation_name
        key.tableize
      end

      def aggregate_function
        :count
      end

      def conditions
        nil
      end

      def base_relation
        return context_record.public_send(relation_name) if context_record
        model_class
      end

      def model_class
        key.camelize.constantize
      end

      def filtered_relation
        relation = base_relation
        filters.each do |filter|
          relation = filter.apply(relation)
        end
        relation
      end

      def normalized_properties
        all_properties = properties
        all_properties[:filters] = filters.map(&:normalized_properties)
        all_properties
      end
    end
  end
end
