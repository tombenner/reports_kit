module ReportsKit
  module Reports
    module Data
      class TwoDimensions
        attr_accessor :dimension, :second_dimension, :dimension_keys_values

        def initialize(dimension, second_dimension, dimension_keys_values)
          self.dimension = dimension
          self.second_dimension = second_dimension
          self.dimension_keys_values = dimension_keys_values
        end

        def perform
          key_pairs = dimension_keys_values.keys

          dimension_ids = key_pairs.map(&:first)
          dimension_ids_dimension_instances = Utils.dimension_to_dimension_ids_dimension_instances(dimension, dimension_ids)

          second_dimension_ids = key_pairs.map(&:last)
          second_dimension_ids_dimension_instances = Utils.dimension_to_dimension_ids_dimension_instances(second_dimension, second_dimension_ids)

          key_1s_key_2s_values = dimensions_keys_values_to_key_1s_key_2s_values(dimension, dimension_keys_values)
          label_1s_label_2s_values = key_1s_key_2s_values_to_label_1s_label_2s_values(
            key_1s_key_2s_values,
            dimension,
            second_dimension,
            dimension_ids_dimension_instances,
            second_dimension_ids_dimension_instances
          )

          chart_items = label_1s_label_2s_values_to_chart_items(label_1s_label_2s_values)
          chart_items
        end

        private

        def dimensions_keys_values_to_key_1s_key_2s_values(dimension, dimension_keys_values)
          key_1s_key_2s_values = {}
          dimension_keys_values.each do |(key_1, key_2), value|
            next if value.zero? || key_1.blank? || key_2.blank?
            key_1s_key_2s_values[key_1] ||= {}
            key_1s_key_2s_values[key_1][key_2] = value.round(Generate::ROUND_PRECISION)
          end
          key_1s_key_2s_values = Utils.populate_sparse_values(key_1s_key_2s_values, use_first_value_key: true)

          if dimension.should_be_sorted_by_count?
            key_1s_key_2s_values = key_1s_key_2s_values.sort_by do |key_1, key_2s_values|
              key_2s_values.values.sum
            end.reverse
          end
          key_1s_key_2s_values
        end

        def key_1s_key_2s_values_to_label_1s_label_2s_values(key_1s_key_2s_values, dimension, second_dimension, dimension_ids_dimension_instances, second_dimension_ids_dimension_instances)
          label_1s_label_2s_values = {}
          key_1s_key_2s_values.each do |key_1, key_2s_values|
            key_2s_values.each do |key_2, value|
              label_1 = Utils.dimension_key_to_label(key_1, dimension_ids_dimension_instances, dimension)
              label_2 = Utils.dimension_key_to_label(key_2, second_dimension_ids_dimension_instances, second_dimension)
              label_1s_label_2s_values[label_1] ||= {}
              label_1s_label_2s_values[label_1][label_2] = value
            end
          end
          limit = dimension.dimension_instances_limit
          if dimension.should_be_sorted_by_count?
            label_1s_label_2s_values = label_1s_label_2s_values.take(limit)
          else
            label_1s_label_2s_values = label_1s_label_2s_values.to_a.last(limit)
          end
          label_1s_label_2s_values
        end

        def label_1s_label_2s_values_to_chart_items(label_1s_label_2s_values)
          chart_items = []
          label_1s_label_2s_values.map! do |label_1, label_2s_values|
            [label_1, label_2s_values]
          end
          all_label1s = label_1s_label_2s_values.map(&:first)
          label_2s_label_1s_values = {}
          label_1s_label_2s_values.each do |label_1, label_2s_values|
            label_2s_values.each do |label_2, value|
              label_2s_label_1s_values[label_2] ||= {}
              label_2s_label_1s_values[label_2][label_1] = value
            end
          end
          label_2s_label_1s_values.each do |label_2, label_1s_values|
            label_1s_values = Hash[label_1s_values]
            values = all_label1s.map do |label_1|
              {
                x: label_1,
                y: label_1s_values[label_1] || 0
              }
            end
            chart_items << {
              key: label_2,
              values: values
            }
          end
          chart_items
        end
      end
    end
  end
end
