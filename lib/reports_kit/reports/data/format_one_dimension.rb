module ReportsKit
  module Reports
    module Data
      class FormatOneDimension
        attr_accessor :measures_results, :measures

        delegate :order_column, :order_direction, to: :primary_dimension_with_measure

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
          sorted_measures_results.map do |measure, result|
            values = result.values.map { |value| value.round(Generate::ROUND_PRECISION) }
            {
              label: measure.label,
              data: values
            }
          end
        end

        def dimension_keys
          sorted_measures_results.first.last.keys
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

        def sorted_measures_results
          @sorted_measures_results ||= begin
            if order_column == 'time'
              sorted_measures_results = measures_results.map do |measure, dimension_keys_values|
                sorted_dimension_keys_values = dimension_keys_values.sort_by(&:first)
                sorted_dimension_keys_values = sorted_dimension_keys_values.reverse if order_direction == 'desc'
                [measure, Hash[sorted_dimension_keys_values]]
              end
            elsif order_column == 'count'
              dimension_keys_sums = Hash.new(0)
              measures_results.values.each do |dimension_keys_values|
                dimension_keys_values.each do |dimension_key, value|
                  dimension_keys_sums[dimension_key] += value
                end
              end
              sorted_dimension_keys = dimension_keys_sums.sort_by(&:last).map(&:first)
              sorted_dimension_keys = sorted_dimension_keys.reverse if order_direction == 'desc'
              sorted_measures_results = measures_results.map do |measure, dimension_keys_values|
                dimension_keys_values = dimension_keys_values.sort_by { |dimension_key, _| sorted_dimension_keys.index(dimension_key) }
                [measure, Hash[dimension_keys_values]]
              end
            else
              sorted_measures_results = measures_results
            end
            Hash[sorted_measures_results]
          end
        end
      end
    end
  end
end
