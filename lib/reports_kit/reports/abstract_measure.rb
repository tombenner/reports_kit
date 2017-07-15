module ReportsKit
  module Reports
    class AbstractMeasure
      def value_format_method
        value_format_method_name = properties[:value_format_method]
        return unless value_format_method_name
        value_format_method = ReportsKit.configuration.custom_methods[value_format_method_name.to_sym]
        raise ArgumentError.new("A value_format_method named '#{value_format_method_name}' is not defined") unless value_format_method
        value_format_method
      end
    end
  end
end
