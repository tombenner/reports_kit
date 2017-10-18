module ReportsKit
  module Reports
    class ModelSettings
      attr_accessor :model_class, :model_configuration_type, :key

      def initialize(model_class, model_configuration_type, key)
        self.model_class = model_class
        self.model_configuration_type = model_configuration_type
        self.key = key
      end

      def settings_from_model
        return {} if model_configuration.blank?
        config_hashes = model_configuration.public_send(model_configuration_type)
        return {} if config_hashes.blank?
        config_hash = config_hashes.find do |hash|
          hash[:key] == key
        end
        config_hash || {}
      end

      private

      def model_configuration
        return unless model_class && model_class.respond_to?(:reports_kit_configuration)
        model_class.reports_kit_configuration
      end
    end
  end
end
