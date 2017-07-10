module ReportsKit
  module Reports
    module Data
      class Aggregation
        attr_accessor :aggregation, :properties, :context_record

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

        def initialize(properties, context_record:)
          self.properties = properties
          self.aggregation = properties[:aggregation]
          self.context_record = context_record
        end

        def perform
          return measures_results_for_one_dimension if dimension_count == 1
          return measures_results_for_two_dimensions if dimension_count == 2
          raise ArgumentError.new("Aggregations' measures can only have 1-2 dimensions")
        end

        private

        def measures_results_for_one_dimension
          measures_results = Hash[measures.map { |measure| [measure, OneDimension.new(measure).perform] }]
          measures_results = Data::PopulateOneDimension.new(measures_results).perform
          value_lists = measures_results.values.map(&:values)
          aggregated_values = value_lists.transpose.map { |data| reduce(data) }
          dimension_keys = measures_results.values.first.keys
          aggregated_keys_values = Hash[dimension_keys.zip(aggregated_values)]
          aggregated_keys_values
        end

        def measures_results_for_two_dimensions
          measures_results = Hash[measures.map { |measure| [measure, TwoDimensions.new(measure).perform] }]
          measures_results = Data::PopulateTwoDimensions.new(measures_results).perform
          value_lists = measures_results.values.map(&:values)
          aggregated_values = value_lists.transpose.map { |data| reduce(data) }
          dimension_keys = measures_results.values.first.keys
          aggregated_keys_values = Hash[dimension_keys.zip(aggregated_values)]
          aggregated_keys_values
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

        def measures
          @measures ||= Measure.new_from_properties!(properties, context_record: context_record)
        end
      end
    end
  end
end
