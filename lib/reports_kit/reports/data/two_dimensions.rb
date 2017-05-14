module ReportsKit
  module Reports
    module Data
      class TwoDimensions
        attr_accessor :measure, :dimension, :second_dimension

        def initialize(measure, dimension, second_dimension)
          self.measure = measure
          self.dimension = dimension
          self.second_dimension = second_dimension
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
            relation = measure.conditions.call(relation) if measure.conditions
            relation = relation.group(dimension.group_expression, second_dimension.group_expression)

            relation = relation.joins(dimension.joins) if dimension.joins
            relation = relation.joins(second_dimension.joins) if second_dimension.joins

            if dimension.should_be_sorted_by_count?
              relation = relation.order('1 DESC')
            else
              relation = relation.order('2')
            end
            dimension_keys_values = relation.count

            if dimension.should_be_sorted_by_count?
              dimension_keys_values = sort_dimension_keys_values_by_count(dimension_keys_values)
            end
            Hash[dimension_keys_values]
          end
        end

        def primary_keys_secondary_keys_values
          @primary_keys_secondary_keys_values ||= begin
            primary_keys_secondary_keys_values = {}
            dimension_keys_values.each do |(primary_key, secondary_key), value|
              primary_keys_secondary_keys_values[primary_key] ||= {}
              primary_keys_secondary_keys_values[primary_key][secondary_key] = value
            end
            primary_keys_secondary_keys_values
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

        def dimension_ids
          dimension_keys_values.keys.map(&:first)
        end

        def dimension_ids_dimension_instances
          @dimension_ids_dimension_instances ||= begin
            Utils.dimension_to_dimension_ids_dimension_instances(dimension, dimension_keys_values.keys.map(&:first))
          end
        end

        def second_dimension_ids_dimension_instances
          @second_dimension_ids_dimension_instances ||= begin
            Utils.dimension_to_dimension_ids_dimension_instances(second_dimension, dimension_keys_values.keys.map(&:last))
          end
        end

        def datasets
          secondary_keys_values = secondary_keys.map do |secondary_key|
            values = primary_keys.map do |primary_key|
              primary_keys_secondary_keys_values[primary_key].try(:[], secondary_key) || 0
            end
            [secondary_key, values]
          end
          secondary_keys_values = secondary_keys_values.sort_by { |_, values| values.sum }.reverse
          secondary_keys_values.map do |secondary_key, values|
            {
              label: Utils.dimension_key_to_label(secondary_key, second_dimension, second_dimension_ids_dimension_instances),
              data: values
            }
          end
        end

        def primary_keys
          @primary_keys ||= begin
            keys = Utils.populate_sparse_keys(dimension_keys_values.keys.map(&:first).uniq)
            if dimension.should_be_sorted_by_count?
              keys = keys.first(dimension.dimension_instances_limit)
            end
            keys
          end
        end

        def secondary_keys
          @secondary_keys ||= begin
            limit = second_dimension.dimension_instances_limit
            Utils.populate_sparse_keys(dimension_keys_values.keys.map(&:last).uniq).first(limit)
          end
        end

        def labels
          primary_keys.map do |primary_key|
            Utils.dimension_key_to_label(primary_key, dimension, dimension_ids_dimension_instances)
          end
        end
      end
    end
  end
end
