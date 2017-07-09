module ReportsKit
  module Reports
    module Data
      class FormatTwoDimensions
        attr_accessor :measure, :dimension, :second_dimension, :dimension_keys_values

        def initialize(measure, dimension_keys_values)
          self.measure = measure
          self.dimension = measure.dimensions[0]
          self.second_dimension = measure.dimensions[1]
          self.dimension_keys_values = dimension_keys_values
        end

        def perform
          {
            labels: labels,
            datasets: datasets
          }
        end

        private

        def labels
          primary_keys.map do |primary_key|
            Utils.dimension_key_to_label(primary_key, dimension, dimension_ids_dimension_instances)
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
            next if secondary_key.blank?
            {
              label: Utils.dimension_key_to_label(secondary_key, second_dimension, second_dimension_ids_dimension_instances),
              data: values
            }
          end.compact
        end

        def populated_dimension_keys_values
          secondary_keys_values = secondary_keys.map do |secondary_key|
            values = primary_keys.map do |primary_key|
              primary_keys_secondary_keys_values[primary_key].try(:[], secondary_key) || 0
            end
            [secondary_key, values]
          end
          secondary_keys_values = secondary_keys_values.sort_by { |_, values| values.sum }.reverse
          secondary_keys_values
        end

        def primary_keys_secondary_keys_values
          @primary_keys_secondary_keys_values ||= begin
            primary_keys_secondary_keys_values = {}
            dimension_keys_values.each do |(primary_key, secondary_key), value|
              primary_key = primary_key.to_date if primary_key.is_a?(Time)
              secondary_key = secondary_key.to_date if secondary_key.is_a?(Time)
              primary_keys_secondary_keys_values[primary_key] ||= {}
              primary_keys_secondary_keys_values[primary_key][secondary_key] = value
            end
            primary_keys_secondary_keys_values
          end
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

        def primary_keys
          @primary_keys ||= begin
            keys = Utils.populate_sparse_keys(dimension_keys_values.keys.map(&:first).uniq, dimension: dimension)
            if dimension.should_be_sorted_by_count?
              limit = dimension.dimension_instances_limit
              keys = keys.first(limit) if limit
            end
            keys
          end
        end

        def secondary_keys
          @secondary_keys ||= begin
            keys = Utils.populate_sparse_keys(dimension_keys_values.keys.map(&:last).uniq, dimension: second_dimension)
            limit = second_dimension.dimension_instances_limit
            keys = keys.first(limit) if limit
            keys
          end
        end
      end
    end
  end
end
