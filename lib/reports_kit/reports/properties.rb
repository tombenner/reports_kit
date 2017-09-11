module ReportsKit
  module Reports
    class Properties
      def self.generate(context)
        properties = context.instance_eval(&ReportsKit.configuration.properties_method)
        properties.deep_symbolize_keys
      end
    end
  end
end
