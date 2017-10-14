module ReportsKit
  module Reports
    class Series < AbstractSeries
      VALID_KEYS = [:measure, :dimensions, :filters, :limit, :report_options]

      attr_accessor :properties, :dimensions, :filters, :context_record

      def initialize(properties, context_record: nil)
        properties = { measure: properties } if properties.is_a?(String)
        properties = properties.deep_symbolize_keys.dup
        measure_properties = properties[:measure]
        properties[:measure] = measure_properties
        properties[:measure] = { key: properties[:measure] } if properties[:measure].is_a?(String)
        raise ArgumentError.new("Measure properties must be a String or Hash, not a #{properties.class.name}: #{properties.inspect}") unless properties.is_a?(Hash)

        dimension_hashes = properties[:dimensions] || []
        dimension_hashes = dimension_hashes.values if dimension_hashes.is_a?(Hash) && dimension_hashes.key?(:'0')
        filter_hashes = properties[:filters] || []
        filter_hashes = filter_hashes.values if filter_hashes.is_a?(Hash) && filter_hashes.key?(:'0')

        self.properties = properties
        self.context_record = context_record
        self.dimensions = dimension_hashes.map { |dimension_hash| DimensionWithSeries.new(dimension: Dimension.new(dimension_hash), series: self) }
        self.filters = filter_hashes.map { |filter_hash| FilterWithSeries.new(filter: Filter.new(filter_hash), series: self) }
      end

      def key
        properties[:measure][:key].underscore
      end

      def label
        properties[:measure][:name].presence || key.pluralize.titleize
      end

      def limit
        properties[:limit]
      end

      def edit_relation_method
        ReportsKit.configuration.custom_method(properties[:report_options].try(:[], :edit_relation_method))
      end

      def relation_name
        key.tableize
      end

      def aggregate_function
        aggregation_expression || [:count, model_class.primary_key]
      end

      def aggregation_expression
        return unless aggregation_config
        expression = aggregation_config[:expression]
        if expression.is_a?(Array)
          expression
        else
          raise ArgumentError.new("The '#{aggregation_key}' aggregation on the #{model_class} model isn't valid")
        end
      end

      def aggregation_key
        properties[:measure][:aggregation]
      end

      def aggregation_config
        @aggregation_config ||= begin
          return unless aggregation_key
          raise ArgumentError.new("A '#{aggregation_key}' aggregation on the #{model_class} model hasn't been configured") unless model_class.respond_to?(:reports_kit_configuration)
          config = model_class.reports_kit_configuration.aggregations.find { |aggregation| aggregation[:key] == aggregation_key }
          raise ArgumentError.new("A '#{aggregation_key}' aggregation on the #{model_class} model hasn't been configured") unless config
          config
        end
      end

      def base_relation
        return context_record.public_send(relation_name) if context_record
        model_class
      end

      def model_class
        if context_record
          reflection = context_record.class.reflect_on_association(key.to_sym) ||
            context_record.class.reflect_on_association(key.pluralize.to_sym)
          return reflection.klass if reflection
        end
        key.camelize.constantize
      end

      def filtered_relation
        relation = base_relation
        filters.each do |filter|
          relation = filter.apply(relation)
        end
        relation
      end

      def has_two_dimensions?
        dimensions.length == 2
      end

      def self.new_from_properties!(properties, context_record:)
        series_hashes = properties[:series].presence || properties.slice(*Series::VALID_KEYS)
        series_hashes = [series_hashes] if series_hashes.is_a?(Hash)
        raise ArgumentError.new('At least one series must be configured') if series_hashes.blank?

        series_hashes.map do |series_hash|
          if series_hash[:composite_operator].present?
            CompositeSeries.new(series_hash, context_record: context_record)
          else
            new(series_hash, context_record: context_record)
          end
        end
      end
    end
  end
end
