module ReportsKit
  module Reports
    module Data
      class OneDimension
        attr_accessor :dimension, :dimension_keys_values

        def initialize(dimension, dimension_keys_values)
          self.dimension = dimension
          self.dimension_keys_values = dimension_keys_values
        end

        def perform
          dimension_ids = dimension_keys_values.keys
          dimension_ids_dimension_instances = Utils.dimension_to_dimension_ids_dimension_instances(dimension, dimension_ids)

          labels_values = dimension_keys_values.map do |dimension_instance, value|
            dimension_label = Utils.dimension_key_to_label(dimension_instance, dimension_ids_dimension_instances, dimension)
            [dimension_label, value.round(Generate::ROUND_PRECISION)]
          end
          labels_values
        end
      end
    end
  end
end
