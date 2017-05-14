module ReportsKit
  module Reports
    module Data
      class OneDimension
        attr_accessor :measure, :dimension

        def initialize(measure, dimension)
          self.measure = measure
          self.dimension = dimension
        end

        def perform
          {
            chart_data: {
              labels: labels,
              datasets: datasets
            }
          }
        end

        private

        def dimension_keys_values
          @dimension_keys_values ||= begin
            relation = measure.filtered_relation
            relation = relation.group(dimension.group_expression)
            relation = relation.joins(dimension.joins) if dimension.joins
            relation = relation.limit(dimension.dimension_instances_limit) if dimension.dimension_instances_limit
            if dimension.should_be_sorted_by_count?
              relation = relation.order('1 DESC')
            else
              relation = relation.order('2')
            end
            dimension_keys_values = relation.distinct.public_send(*measure.aggregate_function)
            dimension_keys_values = Utils.populate_sparse_values(dimension_keys_values)
            dimension_keys_values.delete(nil)
            dimension_keys_values.delete('')
            dimension_keys_values
          end
        end

        def datasets
          [
            {
              label: measure.label,
              data: values
            }
          ]
        end

        def values
          dimension_keys_values.values.map { |value| value.round(Generate::ROUND_PRECISION) }
        end

        def labels
          keys = dimension_keys_values.keys
          keys.map do |key|
            Utils.dimension_key_to_label(key, dimension, dimension_ids_dimension_instances)
          end
        end

        def dimension_ids_dimension_instances
          @dimension_ids_dimension_instances ||= begin
            dimension_ids = dimension_keys_values.keys
            Utils.dimension_to_dimension_ids_dimension_instances(dimension, dimension_ids)
          end
        end
      end
    end
  end
end
