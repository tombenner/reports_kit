module ReportsKit
  module Reports
    class InferrableConfiguration
      COLUMN_TYPES_CLASSES = {
        datetime: Time
      }

      attr_accessor :inferrable, :inferrable_type

      delegate :key, :measure, to: :inferrable

      def initialize(inferrable, inferrable_type)
        self.inferrable = inferrable
        self.inferrable_type = inferrable_type
      end

      def configuration_strategy
        if properties_from_model
          :model
        elsif reflection
          :association
        elsif instance_class_for_column == Time
          :time
        else
          raise ArgumentError.new("No configuration found for #{inferrable_type} with key: '#{key}'")
        end
      end

      def configured_by_association?
        configuration_strategy == :association
      end

      def configured_by_model?
        configuration_strategy == :model
      end

      def configured_by_time?
        configuration_strategy == :time
      end

      def properties_from_model
        return if model_configuration.blank?
        return if model_configuration.public_send(inferrable_type).blank?
        config_hash = model_configuration.public_send(inferrable_type).find do |config_hash|
          config_hash[:key] == key
        end
        config_hash
      end

      def reflection
        model_class.reflect_on_association(key)
      end

      def instance_class
        return reflection.class_name.constantize if reflection
        nil
      end

      def instance_class_for_column
        type = model_class.columns_hash[key.to_s].try(:type)
        return nil if type.blank?
        klass = COLUMN_TYPES_CLASSES[type]
        return nil if klass.blank?
        klass
      end

      def model_configuration
        return unless model_class && model_class.respond_to?(:reports_kit_configuration)
        model_class.reports_kit_configuration
      end

      def model_class
        return unless measure
        measure.model_class
      end
    end
  end
end
