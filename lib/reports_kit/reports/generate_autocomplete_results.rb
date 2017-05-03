module ReportsKit
  module Reports
    class GenerateAutocompleteResults
      attr_accessor :measure_key, :filter_key

      def initialize(params)
        self.measure_key = params[:measure_key]
        self.filter_key = params[:filter_key]
      end

      def perform
        measure = Measure.new(measure_key)
        filter = Filter.new(filter_key, measure: measure)
        model = filter.instance_class
        model.limit(100)
      end
    end
  end
end
