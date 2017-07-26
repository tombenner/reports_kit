module ReportsKit
  module Reports
    module Data
      class FormatOneDimension
        attr_accessor :serieses_results, :serieses, :order

        def initialize(serieses_results, order:)
          self.serieses_results = serieses_results
          self.serieses = serieses_results.keys
          self.order = order
        end

        def perform
          {
            entities: entities,
            datasets: datasets
          }
        end

        private

        def entities
          sorted_dimension_keys.map do |key|
            Utils.dimension_key_to_entity(key, primary_dimension_with_series, dimension_ids_dimension_instances)
          end
        end

        def datasets
          sorted_serieses_results.map do |series, result|
            values = result.values.map do |raw_value|
              Utils.raw_value_to_value(raw_value, series.value_format_method)
            end
            {
              entity: series,
              values: values
            }
          end
        end

        def dimension_summaries
          @dimension_summaries ||= dimension_keys.map do |dimension_key|
            label = Utils.dimension_key_to_label(dimension_key, primary_dimension_with_series, dimension_ids_dimension_instances)
            [dimension_key, label]
          end
        end

        def sorted_dimension_keys
          sorted_serieses_results.first.last.keys
        end

        def dimension_keys_sorted_by_label
          @dimension_keys_sorted_by_label ||= dimension_summaries.sort_by(&:last).map(&:first)
        end

        def dimension_keys
          serieses_results.first.last.keys
        end

        def dimension_ids_dimension_instances
          @dimension_ids_dimension_instances ||= begin
            dimension_ids = dimension_keys
            Utils.dimension_to_dimension_ids_dimension_instances(primary_dimension_with_series, dimension_ids)
          end
        end

        def primary_dimension_with_series
          @primary_dimension_with_series ||= DimensionWithSeries.new(dimension: primary_series.dimensions.first, series: primary_series)
        end

        def primary_series
          serieses.first
        end

        def sorted_serieses_results
          @sorted_serieses_results ||= begin
            if order.relation == 'dimension1' && order.field == 'label'
              sorted_serieses_results = serieses_results.map do |series, dimension_keys_values|
                sorted_dimension_keys_values = dimension_keys_values.sort_by { |key, _| dimension_keys_sorted_by_label.index(key) }
                sorted_dimension_keys_values = sorted_dimension_keys_values.reverse if order.direction == 'desc'
                [series, Hash[sorted_dimension_keys_values]]
              end
            elsif (order.relation == 'dimension1' && order.field.nil?) || (order.relation == 0)
              sorted_serieses_results = serieses_results.map do |series, dimension_keys_values|
                sorted_dimension_keys_values = dimension_keys_values.sort_by(&:first)
                sorted_dimension_keys_values = sorted_dimension_keys_values.reverse if order.direction == 'desc'
                [series, Hash[sorted_dimension_keys_values]]
              end
            elsif order.relation.is_a?(Fixnum)
              series_index = order.relation - 1
              raise ArgumentError.new("Invalid order column: #{order.relation}") unless series_index.in?((0..(serieses_results.length - 1)))
              dimension_keys_values = serieses_results.values.to_a[series_index]
              sorted_dimension_keys = dimension_keys_values.sort_by(&:last).map(&:first)
              sorted_dimension_keys = sorted_dimension_keys.reverse if order.direction == 'desc'
              sorted_serieses_results = serieses_results.map do |series, dimension_keys_values|
                dimension_keys_values = dimension_keys_values.sort_by { |dimension_key, _| sorted_dimension_keys.index(dimension_key) }
                [series, Hash[dimension_keys_values]]
              end
            elsif order.relation == 'count'
              dimension_keys_sums = Hash.new(0)
              serieses_results.values.each do |dimension_keys_values|
                dimension_keys_values.each do |dimension_key, value|
                  dimension_keys_sums[dimension_key] += value
                end
              end
              sorted_dimension_keys = dimension_keys_sums.sort_by(&:last).map(&:first)
              sorted_dimension_keys = sorted_dimension_keys.reverse if order.direction == 'desc'
              sorted_serieses_results = serieses_results.map do |series, dimension_keys_values|
                dimension_keys_values = dimension_keys_values.sort_by { |dimension_key, _| sorted_dimension_keys.index(dimension_key) }
                [series, Hash[dimension_keys_values]]
              end
            else
              sorted_serieses_results = serieses_results
            end
            Hash[sorted_serieses_results]
          end
        end
      end
    end
  end
end
