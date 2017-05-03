module ReportsKit
  module Reports
    class GenerateAutocompleteResults
      attr_accessor :params, :measure_key, :filter_key

      def initialize(params)
        self.params = params
        self.measure_key = params[:measure_key]
        self.filter_key = params[:filter_key]
      end

      def perform
        measure = Measure.new(measure_key)
        filter = Filter.new(filter_key, measure: measure)
        model = filter.instance_class
        results = model.limit(100)
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
    end
  end
end
