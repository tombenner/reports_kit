module ReportsKit
  module Reports
    class Dimension
      DEFAULT_DIMENSION_INSTANCES_LIMIT = 50

      attr_accessor :properties, :measure, :configuration

      delegate :configured_by_association?, :configured_by_column?, :configured_by_model?, :configured_by_time?,
        :settings_from_model, :reflection, :instance_class, :model_class,
        to: :configuration

      def initialize(properties, measure:)
        self.configuration = InferrableConfiguration.new(self, :dimensions)
        self.measure = measure

        raise ArgumentError.new('Blank properties') if properties.blank?
        properties = { key: properties } if properties.is_a?(String)
        properties = properties.deep_symbolize_keys
        self.properties = properties
        if settings && !settings.key?(:group)
          raise ArgumentError.new("Dimension settings for dimension '#{key}' of #{model_class} must include :group")
        end
      end

      def key
        properties[:key]
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
          reflection.foreign_key
        elsif configured_by_column? && configured_by_time?
          "date_trunc('week', #{key}::timestamp)"
        else
          raise ArgumentError.new('Invalid group_expression')
        end
      end

      def group_joins
        nil
      end

      def dimension_instances_limit
        settings[:limit] || DEFAULT_DIMENSION_INSTANCES_LIMIT
      end

      def should_be_sorted_by_count?
        !configured_by_time?
      end
    end
  end
end
