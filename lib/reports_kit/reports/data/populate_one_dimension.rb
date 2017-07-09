module ReportsKit
  module Reports
    module Data
      class PopulateOneDimension
        attr_accessor :sparse_measures_dimension_keys_values

        def initialize(sparse_measures_dimension_keys_values)
          self.sparse_measures_dimension_keys_values = sparse_measures_dimension_keys_values
        end

        def perform
          return sparse_measures_dimension_keys_values if sparse_measures_dimension_keys_values.length == 1
          measures_dimension_keys_values
        end

        private

        def measures_dimension_keys_values
          keys_sums = Hash.new(0)
          measures_dimension_keys_values = sparse_measures_dimension_keys_values.map do |measure, dimension_keys_values|
            dimension_keys.each do |key|
              dimension_keys_values[key] ||= 0
              keys_sums[key] += dimension_keys_values[key]
            end
            [measure, dimension_keys_values]
          end
          if should_be_sorted_by_count?
            sorted_keys = keys_sums.sort_by(&:last).reverse.map(&:first)
          else
            sorted_keys = dimension_keys.sort
          end
          measures_dimension_keys_values = measures_dimension_keys_values.map do |measure, dimension_keys_values|
            dimension_keys_values = Hash[dimension_keys_values.sort_by { |key, value| sorted_keys.index(key) }]
            [measure, dimension_keys_values]
          end
          Hash[measures_dimension_keys_values]
        end

        def dimension_keys
          sparse_measures_dimension_keys_values.map do |measure, dimension_keys_values|
            dimension_keys_values.keys
          end.reduce(&:+).uniq
        end

        def measures
          sparse_measures_dimension_keys_values.keys
        end

        def primary_measure
          measures.first
        end

        def primary_dimension_with_measure
          @primary_dimension_with_measure ||= DimensionWithMeasure.new(dimension: primary_measure.dimensions.first, measure: primary_measure)
        end

        def should_be_sorted_by_count?
          return @should_be_sorted_by_count unless @should_be_sorted_by_count.nil?
          @should_be_sorted_by_count = primary_dimension_with_measure.should_be_sorted_by_count?
        end
      end
    end
  end
end
