module ReportsKit
  module Reports
    module Data
      class Aggregation
        attr_accessor :aggregation, :measures, :properties

        AGGREGATIONS_OPERATORS = {
          '+' => :+,
          '-' => :-,
          '*' => :*,
          '/' => :/,
          '%' => -> (values) {
            raise ArgumentError.new("Percentage aggregations must have exactly two measures") if values.length != 2
            numerator, denominator = values
            return 0 if denominator == 0
            ((numerator.to_f / denominator) * 100).round(1)
          }
        }

        def initialize(properties, measures)
          self.properties = properties
          self.aggregation = properties[:aggregation]
          self.measures = measures
        end

        def perform
          return measures_results_for_one_dimension if dimension_count == 1
          raise ArgumentError.new("Aggregations' measures can only have one dimension")
        end

        private

        def measures_results_for_one_dimension
          measures_results = Hash[measures.map { |measure| [measure, OneDimension.new(measure).perform] }]
          measures_results = Data::PopulateOneDimension.new(measures_results).perform
          value_lists = measures_results.values.map(&:values)
          aggregated_values = value_lists.transpose.map { |data| reduce(data) }
          dimension_keys = measures_results.values.first.keys
          aggregated_keys_values = Hash[dimension_keys.zip(aggregated_values)]
          { aggregation_measure => aggregated_keys_values }
        end

        def aggregation_measure
          AggregationMeasure.new(properties)
        end

        def reduce(values)
          if aggregation_operator.is_a?(Symbol)
            values.reduce(&aggregation_operator)
          elsif aggregation_operator.is_a?(Proc)
            values = aggregation_operator.call(values)
          else
            raise ArgumentError.new("Invalid aggregation operator type: #{aggregation_operator.class}")
          end
        end

        def aggregation_operator
          operator = AGGREGATIONS_OPERATORS[aggregation]
          raise ArgumentError.new("Invalid aggregation: #{aggregation}") unless operator
          operator
        end

        def dimension_count
          unique_dimension_counts = measures.map { |measure| measure.dimensions.length }.uniq
          raise ArgumentError.new('All measures must have the same number of dimensions') if unique_dimension_counts.length > 1
          unique_dimension_counts.first
        end
      end
    end
  end
end
