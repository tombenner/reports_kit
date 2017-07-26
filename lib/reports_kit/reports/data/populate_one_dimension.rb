module ReportsKit
  module Reports
    module Data
      class PopulateOneDimension
        attr_accessor :sparse_serieses_dimension_keys_values

        def initialize(sparse_serieses_dimension_keys_values)
          self.sparse_serieses_dimension_keys_values = sparse_serieses_dimension_keys_values
        end

        def perform
          return sparse_serieses_dimension_keys_values if sparse_serieses_dimension_keys_values.length == 1
          serieses_dimension_keys_values
        end

        private

        def serieses_dimension_keys_values
          serieses_dimension_keys_values = sparse_serieses_dimension_keys_values.map do |series, dimension_keys_values|
            dimension_keys.each do |key|
              dimension_keys_values[key] ||= 0
            end
            [series, dimension_keys_values]
          end
          Hash[serieses_dimension_keys_values]
        end

        def dimension_keys
          sparse_serieses_dimension_keys_values.map do |series, dimension_keys_values|
            dimension_keys_values.keys
          end.reduce(&:+).uniq
        end
      end
    end
  end
end
