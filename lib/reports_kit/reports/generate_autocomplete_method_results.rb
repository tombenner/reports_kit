module ReportsKit
  module Reports
    class GenerateAutocompleteMethodResults
      attr_accessor :filter_key, :params, :properties

      def initialize(filter_key, properties, params)
        self.filter_key = filter_key
        self.params = params
        self.properties = properties
      end

      def perform
        return unless properties[:ui_filters]
        klass, method_name = ReportsKit::Utils.string_to_class_method(autocomplete_method, 'autocomplete_method')
        klass.public_send(method_name, params, properties)
      end

      private

      def filter_hash
        properties[:ui_filters].find { |filter_params| filter_params.is_a?(Hash) && filter_params[:key] == filter_key }
      end

      def autocomplete_method
        filter_hash[:autocomplete_method]
      end
    end
  end
end
