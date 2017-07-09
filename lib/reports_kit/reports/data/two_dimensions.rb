module ReportsKit
  module Reports
    module Data
      class TwoDimensions
        attr_accessor :measure, :dimension, :second_dimension

        def initialize(measure)
          self.measure = measure
          self.dimension = measure.dimensions[0]
          self.second_dimension = measure.dimensions[1]
        end

        def perform
          dimension_keys_values
        end

        private

        def dimension_keys_values
          @dimension_keys_values ||= begin
            relation = measure.filtered_relation
            relation = measure.conditions.call(relation) if measure.conditions
            relation = relation.group(dimension.group_expression, second_dimension.group_expression)

            relation = relation.joins(dimension.joins) if dimension.joins
            relation = relation.joins(second_dimension.joins) if second_dimension.joins

            if dimension.should_be_sorted_by_count?
              relation = relation.order('1 DESC')
            else
              relation = relation.order('2')
            end
            dimension_keys_values = relation.distinct.public_send(*measure.aggregate_function)

            if dimension.should_be_sorted_by_count?
              dimension_keys_values = sort_dimension_keys_values_by_count(dimension_keys_values)
            end
            dimension_keys_values = Utils.populate_sparse_hash(dimension_keys_values, dimension: dimension)
            Hash[dimension_keys_values]
          end
        end

        def sort_dimension_keys_values_by_count(dimension_keys_values)
          primary_keys_counts = Hash.new(0)
          dimension_keys_values.each do |(primary_key, secondary_key), count|
            primary_keys_counts[primary_key] += count
          end
          primary_keys_counts = primary_keys_counts.to_a
          sorted_primary_keys = primary_keys_counts.sort_by { |primary_key, count| count }.reverse.map(&:first)
          dimension_keys_values = dimension_keys_values.sort_by { |(primary_key, secondary_key), count| sorted_primary_keys.index(primary_key) }
          Hash[dimension_keys_values]
        end
      end
    end
  end
end
