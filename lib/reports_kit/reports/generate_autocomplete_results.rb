module ReportsKit
  module Reports
    class GenerateAutocompleteResults
      attr_accessor :params, :properties, :filter_key, :filter, :context_params, :context_record

      def initialize(params, properties, context_record: nil)
        self.params = params
        self.properties = properties
        self.context_params = params[:context_params]
        self.filter_key = params[:key]
        self.filter = Reports::PropertiesToFilter.new(properties, context_record: context_record).perform(filter_key)
        self.context_record = context_record
      end

      def perform
        autocomplete_method_results = Reports::GenerateAutocompleteMethodResults.new(filter_key, properties, params).perform
        return autocomplete_method_results if autocomplete_method_results
        raise ArgumentError.new("Could not find a model for filter_key: '#{filter_key}'") unless model
        return autocomplete_results_method.call(params: params, context_record: context_record, relation: relation) if autocomplete_results_method
        results = filter.apply_contextual_filters(relation, context_params)
        results = results.limit(10_000)
        results = results.map { |result| { id: result.id, text: result.to_s } }
        results = results.sort_by { |result| result[:text].downcase }
        results = filter_results(results)
        results.first(100)
      end

      private

      def autocomplete_results_method
        ReportsKit.configuration.autocomplete_results_method
      end

      def relation
        if context_record
          context_record.public_send(filter.context_record_association)
        else
          model
        end
      end

      def filter_results(results)
        query = params[:q].try(:downcase)
        if query.present?
          results = results.to_a.select { |r| r[:text].downcase.include?(query) }
        end
        results
      end

      def model
        @model ||= begin
          filter.instance_class
        end
      end
    end
  end
end
