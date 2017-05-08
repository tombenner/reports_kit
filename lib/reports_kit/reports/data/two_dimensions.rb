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
          {
            chart_data: {
              labels: labels,
              datasets: datasets
            }
          }
        end

        private

        def primary_keys_secondary_keys_values
          primary_keys_secondary_keys_values = {}
          dimension_keys_values.each do |(primary_key, secondary_key), value|
            primary_keys_secondary_keys_values[primary_key] ||= {}
            primary_keys_secondary_keys_values[primary_key][secondary_key] = value
          end
          primary_keys_secondary_keys_values
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
          secondary_keys.map do |secondary_key|
            values = primary_keys.map do |primary_key|
              primary_keys_secondary_keys_values[primary_key].try(:[], secondary_key) || 0
            end
            {
              label: Utils.dimension_key_to_label(secondary_key, second_dimension_ids_dimension_instances),
              data: values
            }
          end
        end

        def primary_keys
          Utils.populate_sparse_keys(dimension_keys_values.keys.map(&:first).uniq)
        end

        def secondary_keys
          Utils.populate_sparse_keys(dimension_keys_values.keys.map(&:last).uniq)
        end

        def labels
          primary_keys.map do |primary_key|
            Utils.dimension_key_to_label(primary_key, dimension_ids_dimension_instances)
          end
        end
      end
    end
  end
end
