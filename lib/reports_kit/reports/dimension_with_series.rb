module ReportsKit
  module Reports
    class DimensionWithSeries
      DEFAULT_GRANULARITY = 'week'
      VALID_GRANULARITIES = %w(day week).freeze
      ADAPTER_NAMES_CLASSES = {
        'mysql2' => Adapters::Mysql,
        'postgresql' => Adapters::Postgresql
      }.freeze

      attr_accessor :dimension, :series, :configuration

      delegate :key, :properties, :label, to: :dimension
      delegate :configured_by_association?, :configured_by_column?, :configured_by_model?, :configured_by_time?,
        :settings_from_model, :reflection, :instance_class, :model_class, :column_type,
        to: :configuration

      def initialize(dimension:, series:)
        self.dimension = dimension
        self.series = series
        self.configuration = InferrableConfiguration.new(self, :dimensions)
        missing_group_setting = settings && !settings.key?(:group)
        raise ArgumentError.new("Dimension settings for dimension '#{key}' of #{model_class} must include :group") if missing_group_setting
      end

      def granularity
        @granularity ||= begin
          return unless configured_by_time?
          granularity = properties[:granularity] || DEFAULT_GRANULARITY
          raise ArgumentError.new("Invalid granularity: #{granularity}") unless VALID_GRANULARITIES.include?(granularity)
          granularity
        end
      end

      def settings
        inferred_settings.merge(settings_from_model)
      end

      def inferred_settings
        configuration.inferred_settings.merge(inferred_dimension_settings)
      end

      def inferred_dimension_settings
        {
          group: group_expression
        }
      end

      def group_expression
        if configured_by_model?
          settings_from_model[:group]
        elsif configured_by_association?
          inferred_settings_from_association[:column]
        elsif configured_by_column? && configured_by_time?
          granularity == 'day' ? day_expression : week_expression
        elsif configured_by_column?
          column_expression
        else
          raise ArgumentError.new('Invalid group_expression')
        end
      end

      def inferred_settings_from_association
        through_reflection = reflection.through_reflection
        if through_reflection
          {
            joins: through_reflection.name,
            column: "#{through_reflection.table_name}.#{reflection.source_reflection.foreign_key}"
          }
        else
          {
            column: "#{model_class.table_name}.#{reflection.foreign_key}"
          }
        end
      end

      def joins
        return settings_from_model[:joins] if configured_by_model?
        inferred_settings_from_association[:joins] if configured_by_association?
      end

      def dimension_instances_limit
        if configured_by_time?
          properties[:limit]
        else
          properties[:limit] || ReportsKit.configuration.default_dimension_limit
        end
      end

      def first_key
        return unless configured_by_time? && datetime_filters.present?
        datetime_filters.map(&:start_at).compact.sort.first
      end

      def last_key
        return unless configured_by_time? && datetime_filters.present?
        datetime_filters.map(&:end_at).compact.sort.last
      end

      def key_to_label(key)
        return unless settings[:key_to_label]
        settings[:key_to_label].call(key)
      end

      def datetime_filters
        return [] unless series.filters.present?
        series.filters.map(&:filter_type).select { |filter_type| filter_type.is_a?(FilterTypes::Datetime) }
      end

      def should_be_sorted_by_count?
        !configured_by_time?
      end

      def adapter
        @adapter ||= begin
          adapter_name = model_class.connection_config[:adapter]
          adapter = ADAPTER_NAMES_CLASSES[adapter_name]
          raise ArgumentError.new("Unsupported adapter: #{adapter_name}") unless adapter
          adapter
        end
      end

      def column_expression
        "#{model_class.table_name}.#{key}"
      end

      def day_expression
        adapter.truncate_to_day(column_expression)
      end

      def week_expression
        adapter.truncate_to_week(column_expression)
      end
    end
  end
end
