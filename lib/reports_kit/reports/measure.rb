module ReportsKit
  module Reports
    class Measure
      attr_accessor :properties, :filters

      def initialize(properties)
        properties = { key: properties } if properties.is_a?(String)
        properties = properties.deep_symbolize_keys
        filter_hashes = properties.delete(:filters) || []
        filter_hashes = filter_hashes.values if filter_hashes.is_a?(Hash) && filter_hashes.key?(:'0')

        self.properties = properties
        self.filters = filter_hashes.map { |filter_hash| Filter.new(filter_hash, measure: self) }
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

      def conditions
        nil
      end

      def base_relation
        model_class
      end

      def model_class
        key.singularize.camelize.constantize
      end

      def filtered_relation
        relation = base_relation
        filters.each do |filter|
          relation = filter.apply(relation)
        end
        relation
      end

      def properties_with_filters
        all_properties = properties
        all_properties[:filters] = filters.map(&:properties)
        all_properties
      end
    end
  end
end
