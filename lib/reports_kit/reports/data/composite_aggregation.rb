module ReportsKit
  module Reports
    module Data
      class CompositeAggregation
        attr_accessor :composite_series, :context_record

        delegate :composite_operator, :properties, :limit, to: :composite_series

        OPERATORS_METHODS = {
          '+' => :+,
          '-' => :-,
          '*' => :*,
          '/' => :/,
          '%' => -> (values) {
            raise ArgumentError.new("Percentage composite aggregations must have exactly two series") if values.length != 2
            numerator, denominator = values
            return 0 if denominator == 0
            ((numerator.to_f / denominator) * 100).round(1)
          }
        }

        def initialize(properties, context_record:)
          self.composite_series = CompositeSeries.new(properties)
          self.context_record = context_record
        end

        def perform
          return serieses_results_for_one_dimension if dimension_count == 1
          return serieses_results_for_two_dimensions if dimension_count == 2
          raise ArgumentError.new("Composite aggregations' series can only have 1-2 dimensions")
        end

        private

        def serieses_results_for_one_dimension
          serieses_results = Hash[serieses.map { |series| [series, OneDimension.new(series).perform] }]
          serieses_results = Data::PopulateOneDimension.new(serieses_results).perform
          sorted_dimension_keys_values = sort_dimension_keys_values(serieses_results)
          value_lists = sorted_dimension_keys_values.map(&:values)
          composited_values = value_lists.transpose.map { |data| reduce(data) }
          dimension_keys = sorted_dimension_keys_values.first.keys
          composited_keys_values = dimension_keys.zip(composited_values)
          composited_keys_values = composited_keys_values.take(limit) if limit
          Hash[composited_keys_values]
        end

        def serieses_results_for_two_dimensions
          serieses_results = Hash[serieses.map { |series| [series, TwoDimensions.new(series).perform] }]
          serieses_results = Data::PopulateTwoDimensions.new(serieses_results).perform
          value_lists = serieses_results.values.map(&:values)
          composited_values = value_lists.transpose.map { |data| reduce(data) }
          dimension_keys = serieses_results.values.first.keys
          composited_keys_values = dimension_keys.zip(composited_values)
          composited_keys_values = composited_keys_values.take(limit) if limit
          Hash[composited_keys_values]
        end

        # Before performing a composition of values, we need to make sure that the values are sorted by the same dimension key.
        def sort_dimension_keys_values(serieses_results)
          dimension_keys_values_list = serieses_results.values
          sorted_dimension_keys_values = dimension_keys_values_list.map do |dimension_keys_values|
            dimension_keys_values = dimension_keys_values.sort_by do |dimension_key, value|
              is_boolean = dimension_key.is_a?(TrueClass) || dimension_key.is_a?(FalseClass)
              is_boolean ? (dimension_key ? 0 : 1) : dimension_key
            end
            Hash[dimension_keys_values]
          end
          sorted_dimension_keys_values
        end

        def reduce(values)
          if composite_method.is_a?(Symbol)
            values.reduce(&composite_method)
          elsif composite_method.is_a?(Proc)
            values = composite_method.call(values)
          else
            raise ArgumentError.new("Invalid composite method type: #{composite_method.class}")
          end
        end

        def composite_method
          composite_method = OPERATORS_METHODS[composite_operator]
          raise ArgumentError.new("Invalid composite_operator: #{composite_operator}") unless composite_method
          composite_method
        end

        def dimension_count
          unique_dimension_counts = serieses.map { |series| series.dimensions.length }.uniq
          raise ArgumentError.new('All series must have the same number of dimensions') if unique_dimension_counts.length > 1
          unique_dimension_counts.first
        end

        def serieses
          @serieses ||= Series.new_from_properties!(properties, context_record: context_record)
        end
      end
    end
  end
end
