module ReportsKit
  module Reports
    class GenerateAutocompleteResults
      attr_accessor :params, :measure_key, :filter_key, :context_record

      def initialize(params, context_record: nil)
        self.params = params
        self.measure_key = params[:measure_key]
        self.filter_key = params[:filter_key]
        self.context_record = context_record
      end

      def perform
        raise ArgumentError.new("Could not find a model for filter_key: '#{filter_key}'") unless model
        results = model
        results = results.public_send(scope) if scope
        results = results.limit(10_000)
        results = results.map { |result| { id: result.id, text: result.to_s } }
        results = results.sort_by { |result| result[:text].downcase }
        results = filter_results(results)
        results
      end

      private

      def filter_results(results)
        query = params[:q].try(:downcase)
        if query.present?
          results = results.to_a.select { |r| r[:text].downcase.include?(query) }
        end
        results
      end

      def model
        @model ||= begin
          measure = Measure.new(measure_key, context_record: context_record)
          filter = Filter.new(filter_key, measure: measure)
          filter.instance_class
        end
      end

      def scope
        @scope ||= begin
          scope = params[:scope]
          return unless scope.present?
          return unless model.try(:reports_kit_configuration) && model.reports_kit_configuration.autocomplete_scopes.present?
          unless model.reports_kit_configuration.autocomplete_scopes.include?(scope)
            raise ArgumentError.new("Unallowed scope '#{scope}' for model #{model.name}")
          end
          scope
        end
      end
    end
  end
end
