module ReportsKit
  module Reports
    module Data
      class PopulateOneDimension
        attr_accessor :sparse_measures_dimension_keys_values

        def initialize(sparse_measures_dimension_keys_values)
          self.sparse_measures_dimension_keys_values = sparse_measures_dimension_keys_values
        end

        def perform
          return sparse_measures_dimension_keys_values if sparse_measures_dimension_keys_values.length == 1
          measures_dimension_keys_values
        end

        private

        def measures_dimension_keys_values
          measures_dimension_keys_values = sparse_measures_dimension_keys_values.map do |measure, dimension_keys_values|
            dimension_keys.each do |key|
              dimension_keys_values[key] ||= 0
            end
            [measure, dimension_keys_values]
          end
          Hash[measures_dimension_keys_values]
        end

        def dimension_keys
          sparse_measures_dimension_keys_values.map do |measure, dimension_keys_values|
            dimension_keys_values.keys
          end.reduce(&:+).uniq
        end
      end
    end
  end
end
