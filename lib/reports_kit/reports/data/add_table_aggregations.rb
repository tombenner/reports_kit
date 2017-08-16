module ReportsKit
  module Reports
    module Data
      class AddTableAggregations
        attr_accessor :data, :report_options

        VALID_AGGREGATION_OPERATORS = [:sum]

        def initialize(data, report_options:)
          self.data = data
          self.report_options = report_options || {}
        end

        def perform
          data_with_aggregations
        end

        private

        def data_with_aggregations
          return data if row_aggregation_configs.blank? && column_aggregation_configs.blank?
          {
            entities: entities,
            datasets: datasets
          }
        end

        def entities
          column_aggregation_entities = column_aggregation_configs.map do |config|
            ReportsKit::Entity.new(config[:label], config[:label], config[:label])
          end
          entities_with_row_aggregations + column_aggregation_entities
        end

        def datasets
          datasets_with_row_aggregations.map do |dataset|
            column_aggregation_configs.each do |config|
              value = aggregate_array(dataset[:values].map(&:formatted), config[:operator])
              dataset[:values] << ReportsKit::Value.new(value, value)
            end
            dataset
          end
        end

        def entities_with_row_aggregations
          @entities_with_row_aggregations ||= begin
            return original_entities if row_aggregation_configs.blank?
            row_aggregation_entities = row_aggregation_configs.map do |config|
              ReportsKit::Entity.new(config[:label], config[:label], config[:label])
            end
            original_entities + row_aggregation_entities
          end
        end

        def datasets_with_row_aggregations
          @datasets_with_row_aggregations ||= begin
            return original_datasets if row_aggregation_configs.blank?
            row_aggregation_datasets = row_aggregation_configs.map do |config|
              values = original_datasets.map { |dataset| dataset[:values].map(&:formatted) }.transpose
              aggregated_values = aggregate_array_of_arrays(values, config[:operator])
              values = aggregated_values.map { |value| ReportsKit::Value.new(value, value) }
              {
                entity: ReportsKit::Entity.new(config[:label], config[:label], config[:label]),
                values: values
              }
            end
            original_datasets + row_aggregation_datasets
          end
        end

        def original_entities
          data[:entities]
        end

        def original_datasets
          data[:datasets]
        end

        def row_aggregation_configs
          return [] if report_options[:aggregations].blank?
          report_options[:aggregations].select { |config| config[:from] == 'rows' }
        end

        def column_aggregation_configs
          return [] if report_options[:aggregations].blank?
          report_options[:aggregations].select { |config| config[:from] == 'columns' }
        end

        def aggregate_array(values, operator)
          operator = operator.try(:to_sym)
          raise ArgumentError.new("Invalid aggregation operator: #{operator}") unless operator.in?(VALID_AGGREGATION_OPERATORS)
          if values.first.is_a?(Numeric)
            values.public_send(operator)
          else
            nil
          end
        end

        def aggregate_array_of_arrays(array_of_arrays, operator)
          array_of_arrays.map { |values| aggregate_array(values, operator) }
        end
      end
    end
  end
end
