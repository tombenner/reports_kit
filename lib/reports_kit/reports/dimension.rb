module ReportsKit
  module Reports
    class Dimension
      DEFAULT_DIMENSION_INSTANCES_LIMIT = 50

      attr_accessor :properties, :measure, :configuration

      delegate :configured_by_association?, :configured_by_model?, :configured_by_time?,
        :properties_from_model, :reflection,
        to: :configuration

      def initialize(properties, measure:)
        self.configuration = InferrableConfiguration.new(self, :dimensions)
        self.measure = measure

        raise ArgumentError.new('Blank properties') if properties.blank?
        properties = { key: properties } if properties.is_a?(String)
        properties = properties.deep_symbolize_keys
        self.properties = properties
        if properties_from_model && !properties_from_model.key?(:group)
          raise ArgumentError.new("Dimension properties for #{model_class} must include :group")
        end
        self.properties = properties_from_model.merge(self.properties) if properties_from_model
      end

      def key
        properties[:key]
      end

      def instance_class
        return reflection.class_name.constantize if reflection
        nil
      end

      def group_expression
        if configured_by_model?
          properties[:group]
        elsif configured_by_association?
          reflection.foreign_key
        elsif configured_by_time?
          "date_trunc('week', #{key}::timestamp)"
        else
          raise ArgumentError.new('Invalid group_expression')
        end
      end

      def group_joins
        nil
      end

      def dimension_instances_limit
        properties[:limit] || DEFAULT_DIMENSION_INSTANCES_LIMIT
      end

      def should_be_sorted_by_count?
        !configured_by_time?
      end
    end
  end
end
