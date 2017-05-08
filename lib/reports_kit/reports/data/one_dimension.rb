module ReportsKit
  module Reports
    module Data
      class OneDimension
        attr_accessor :measure, :dimension, :dimension_keys_values

        def initialize(measure, dimension, dimension_keys_values)
          self.measure = measure
          self.dimension = dimension
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
            Utils.dimension_key_to_label(key, dimension_ids_dimension_instances)
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
