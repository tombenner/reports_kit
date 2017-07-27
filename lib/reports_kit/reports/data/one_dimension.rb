module ReportsKit
  module Reports
    module Data
      class OneDimension
        attr_accessor :series, :dimension

        def initialize(series)
          self.series = series
          self.dimension = series.dimensions[0]
        end

        def perform
          dimension_keys_values
        end

        private

        def dimension_keys_values
          relation = series.filtered_relation
          relation = relation.group(dimension.group_expression)
          relation = relation.joins(dimension.joins) if dimension.joins
          relation = relation.limit(dimension.dimension_instances_limit) if dimension.dimension_instances_limit
          relation = relation.order(order)
          dimension_keys_values = relation.distinct.public_send(*series.aggregate_function)
          dimension_keys_values = Utils.populate_sparse_hash(dimension_keys_values, dimension: dimension)
          dimension_keys_values.delete(nil)
          dimension_keys_values.delete('')
          dimension_keys_values = dimension_keys_values.take(series.limit) if series.limit
          Hash[dimension_keys_values]
        end

        def order
          dimension.configured_by_time? ? '2' : '1 DESC'
        end
      end
    end
  end
end
