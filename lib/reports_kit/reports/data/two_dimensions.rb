module ReportsKit
  module Reports
    module Data
      class TwoDimensions
        attr_accessor :series, :dimension, :second_dimension

        def initialize(series)
          self.series = series
          self.dimension = series.dimensions[0]
          self.second_dimension = series.dimensions[1]
        end

        def perform
          dimension_keys_values
        end

        private

        def dimension_keys_values
          relation = series.filtered_relation
          relation = relation.group(dimension.group_expression, second_dimension.group_expression)
          relation = relation.joins(dimension.joins) if dimension.joins
          relation = relation.joins(second_dimension.joins) if second_dimension.joins
          relation = relation.order(order)
          dimension_keys_values = relation.distinct.public_send(*series.aggregate_function)
          dimension_keys_values = Utils.populate_sparse_hash(dimension_keys_values, dimension: dimension)
          dimension_keys_values.delete(nil)
          dimension_keys_values.delete('')
          Hash[dimension_keys_values]
        end

        def order
          dimension.configured_by_time? ? '2' : '1 DESC'
        end
      end
    end
  end
end
