module ReportsKit
  module Reports
    module Data
      class Aggregation
        attr_accessor :aggregation, :measures, :name

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

        def initialize(aggregation:, name:, measures:)
          self.aggregation = aggregation
          self.measures = measures
          self.name = name
          raise ArgumentError.new('Aggregations must have a "name" attribute') if name.blank?
        end

        def perform
          return data_for_one_dimension if dimension_count == 1
          raise ArgumentError.new("Aggregations' measures can only have one dimension")
        end

        private

        def data_for_one_dimension
          data = OneDimension.new(measures).perform
          individual_datasets = data[:chart_data][:datasets]
          individual_datas = individual_datasets.map { |dataset| dataset[:data] }
          aggregated_data = individual_datas.transpose.map do |data|
            reduce(data)
          end
          dataset = {
            label: name,
            data: aggregated_data
          }
          data[:chart_data][:datasets] = [dataset]
          data
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
