module ReportsKit
  module Model
    extend ActiveSupport::Concern

    included do
      class << self
        attr_accessor :reports_kit_configuration
      end

      def self.reports_kit(&block)
        self.reports_kit_configuration = ModelConfiguration.new
        reports_kit_configuration.instance_eval(&block)
      end
    end
  end
end
