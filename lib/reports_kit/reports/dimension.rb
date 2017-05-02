module ReportsKit
  module Reports
    class Dimension
      DEFAULT_DIMENSION_INSTANCES_LIMIT = 50
      COLUMN_TYPES_CLASSES = {
        datetime: Time
      }

      attr_accessor :properties, :measure

      def initialize(properties, measure:)
        raise ArgumentError.new('Blank properties') if properties.blank?
        properties = { key: properties } if properties.is_a?(String)
        self.properties = properties
        self.measure = measure
      end

      def key
        properties[:key]
      end

      def group_expression
        if properties[:group]
          properties[:group]
        elsif reflection
          reflection.foreign_key
        elsif is_time?
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
        !is_time?
      end

      def instance_class
        return reflection.class_name.constantize if reflection
        nil
      end

      private

      def is_time?
        instance_class_for_column == Time
      end

      def reflection
        measure.model_class.reflect_on_association(key)
      end

      def instance_class_for_column
        type = measure.model_class.columns_hash[key.to_s].try(:type)
        return nil if type.blank?
        klass = COLUMN_TYPES_CLASSES[type]
        return nil if klass.blank?
        klass
      end
    end
  end
end
