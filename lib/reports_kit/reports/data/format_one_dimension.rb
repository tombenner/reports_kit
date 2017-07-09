module ReportsKit
  module Reports
    module Data
      class FormatOneDimension
        attr_accessor :measures_results, :measures

        def initialize(measures_results)
          self.measures_results = measures_results
          self.measures = measures_results.keys
        end

        def perform
          {
            labels: labels,
            datasets: datasets
          }
        end

        private

        def labels
          dimension_keys.map do |key|
            Utils.dimension_key_to_label(key, primary_dimension_with_measure, dimension_ids_dimension_instances)
          end
        end

        def datasets
          measures_results.map do |measure, result|
            values = result.values.map { |value| value.round(Generate::ROUND_PRECISION) }
            {
              label: measure.label,
              data: values
            }
          end
        end

        def dimension_keys
          measures_results.first.last.keys
        end

        def dimension_ids_dimension_instances
          @dimension_ids_dimension_instances ||= begin
            dimension_ids = dimension_keys
            Utils.dimension_to_dimension_ids_dimension_instances(primary_dimension_with_measure, dimension_ids)
          end
        end

        def primary_dimension_with_measure
          @primary_dimension_with_measure ||= DimensionWithMeasure.new(dimension: measures.first.dimensions.first, measure: measures.first)
        end
      end
    end
  end
end
