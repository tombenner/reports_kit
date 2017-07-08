module ReportsKit
  module Reports
    module Data
      class OneDimension
        attr_accessor :measures

        def initialize(measures)
          self.measures = measures
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

        def sparse_measures_dimension_keys_values
          @measures_dimension_keys_values ||= begin
            Hash[measures.map { |measure| [measure, measure_to_dimension_keys_values(measure)] }]
          end
        end

        def dimension_keys
          sparse_measures_dimension_keys_values.map do |measure, dimension_keys_values|
            dimension_keys_values.keys
          end.reduce(&:+).uniq
        end

        def measures_dimension_keys_values
          keys_sums = Hash.new(0)
          measures_dimension_keys_values = sparse_measures_dimension_keys_values.map do |measure, dimension_keys_values|
            dimension_keys.each do |key|
              dimension_keys_values[key] ||= 0
              keys_sums[key] += dimension_keys_values[key]
            end
            [measure, dimension_keys_values]
          end
          if should_be_sorted_by_count?
            sorted_keys = keys_sums.sort_by(&:last).reverse.map(&:first)
          else
            sorted_keys = dimension_keys.sort
          end
          measures_dimension_keys_values = measures_dimension_keys_values.map do |measure, dimension_keys_values|
            dimension_keys_values = Hash[dimension_keys_values.sort_by { |key, value| sorted_keys.index(key) }]
            [measure, dimension_keys_values]
          end
          Hash[measures_dimension_keys_values]
        end

        def should_be_sorted_by_count?
          return @should_be_sorted_by_count unless @should_be_sorted_by_count.nil?
          @should_be_sorted_by_count = primary_dimension_with_measure.should_be_sorted_by_count?
        end

        def measure_to_dimension_keys_values(measure)
          dimension_with_measure = DimensionWithMeasure.new(dimension: measure.dimensions.first, measure: measure)
          relation = measure.filtered_relation
          relation = relation.group(dimension_with_measure.group_expression)
          relation = relation.joins(dimension_with_measure.joins) if dimension_with_measure.joins
          relation = relation.limit(dimension_with_measure.dimension_instances_limit) if dimension_with_measure.dimension_instances_limit
          if dimension_with_measure.should_be_sorted_by_count?
            relation = relation.order('1 DESC')
          else
            relation = relation.order('2')
          end
          dimension_keys_values = relation.distinct.public_send(*measure.aggregate_function)
          dimension_keys_values = Utils.populate_sparse_hash(dimension_keys_values, dimension: dimension_with_measure)
          dimension_keys_values.delete(nil)
          dimension_keys_values.delete('')
          dimension_keys_values
        end

        def datasets
          measures.map do |measure|
            {
              label: measure.label,
              data: values(measure)
            }
          end
        end

        def values(measure)
          measures_dimension_keys_values[measure].values.map { |value| value.round(Generate::ROUND_PRECISION) }
        end

        def labels
          dimension_keys.map do |key|
            Utils.dimension_key_to_label(key, primary_dimension_with_measure, dimension_ids_dimension_instances)
          end
        end

        def dimension_ids_dimension_instances
          @dimension_ids_dimension_instances ||= begin
            dimension_ids = measures_dimension_keys_values[primary_measure].keys
            Utils.dimension_to_dimension_ids_dimension_instances(primary_dimension_with_measure, dimension_ids)
          end
        end

        def primary_measure
          measures.first
        end

        def primary_dimension_with_measure
          @primary_dimension_with_measure ||= DimensionWithMeasure.new(dimension: primary_measure.dimensions.first, measure: primary_measure)
        end
      end
    end
  end
end
