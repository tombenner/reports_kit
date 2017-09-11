module ReportsKit
  module Reports
    class FilterWithSeries
      CONFIGURATION_STRATEGIES_FILTER_TYPE_CLASSES = {
        association: FilterTypes::Records,
        boolean: FilterTypes::Boolean,
        datetime: FilterTypes::Datetime,
        integer: FilterTypes::Number,
        string: FilterTypes::String
      }
      COLUMN_TYPES_FILTER_TYPE_CLASSES = {
        boolean: FilterTypes::Boolean,
        datetime: FilterTypes::Datetime,
        integer: FilterTypes::Number,
        string: FilterTypes::String
      }

      attr_accessor :filter, :series, :configuration

      delegate :key, :expression, :properties, :label, to: :filter
      delegate :configured_by_association?, :configured_by_column?, :configured_by_model?, :configured_by_time?,
        :settings_from_model, :configuration_strategy, :instance_class, :column_type, :column,
        to: :configuration

      def initialize(filter:, series:)
        self.filter = filter
        self.series = series
        self.configuration = InferrableConfiguration.new(self, :filters)

        properties[:criteria] = filter_type.default_criteria unless properties[:criteria]
      end

      def normalized_properties
        return properties unless configured_by_time?
        criteria = properties[:criteria]
        return properties if criteria.blank? || criteria[:value].blank?
        values = criteria[:value].split(ReportsKit::Reports::FilterTypes::Datetime::SEPARATOR)
        values = values.map { |value| ReportsKit::Reports::Data::Utils.format_time_value(value) }
        properties[:criteria][:value] = values.join(ReportsKit::Reports::FilterTypes::Datetime::SEPARATOR)
        properties
      end

      def settings
        inferred_settings.merge(settings_from_model)
      end

      def inferred_settings
        configuration.inferred_settings.merge(inferred_filter_settings)
      end

      def inferred_filter_settings
        {
          column: column
        }
      end

      def context_record_association
        properties[:context_record_association] || instance_class.name.tableize
      end

      def type_klass
        type_klass_for_configuration_strategy = CONFIGURATION_STRATEGIES_FILTER_TYPE_CLASSES[configuration_strategy]
        return type_klass_for_configuration_strategy if type_klass_for_configuration_strategy
        type_klass_for_column_type = COLUMN_TYPES_FILTER_TYPE_CLASSES[column_type]
        return type_klass_for_column_type if type_klass_for_column_type
        return filter_type_class_from_model if configured_by_model?
        raise ArgumentError.new("No configuration found for filter with key: '#{key}'")
      end

      def filter_type
        type_klass.new(settings, properties, primary_dimension: series.dimensions.first)
      end

      def filter_type_class_from_model
        return unless settings
        type_key = settings[:type_key]
        raise ArgumentError.new("No type specified for filter with key: '#{key}'") unless type_key
        type_class = CONFIGURATION_STRATEGIES_FILTER_TYPE_CLASSES[type_key]
        raise ArgumentError.new("Invalid type ('#{type_key}') specified for filter with key: '#{key}'") unless type_class
        type_class
      end

      def apply(relation)
        filter_type.apply_filter(relation)
      end
    end
  end
end
