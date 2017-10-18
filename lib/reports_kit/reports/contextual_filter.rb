module ReportsKit
  module Reports
    class ContextualFilter
      attr_accessor :key, :model_settings

      delegate :settings_from_model, to: :model_settings

      def initialize(key, model_class)
        self.key = key.to_sym
        self.model_settings = ModelSettings.new(model_class, :contextual_filters, self.key)
      end

      def apply(relation, context_params)
        raise ArgumentError.new("contextual_filter with key :#{key} not defined in #{model_class}") if settings_from_model.blank?
        settings_from_model[:method].call(relation, context_params)
      end
    end
  end
end
