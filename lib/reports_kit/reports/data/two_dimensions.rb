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

            # If the dimension's order_column is 'name', we can't sort it in SQL and will instead need to sort it in memory, where we have
            # access to the #to_s method of the dimension instances.
            if dimension.order_column == 'count'
              relation = relation.order("1 #{dimension.order_direction}")
            elsif dimension.order_column == 'time' && dimension.configured_by_time?
              relation = relation.order("2 #{dimension.order_direction}")
            end
            dimension_keys_values = relation.distinct.public_send(*measure.aggregate_function)
            dimension_keys_values = Utils.populate_sparse_hash(dimension_keys_values, dimension: dimension)
            Hash[dimension_keys_values]
          end
        end
      end
    end
  end
end
