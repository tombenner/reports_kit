module ReportsKit
  module Reports
    module Data
      class FormatTable
        attr_accessor :data, :format, :first_column_label, :report_options

        VALID_AGGREGATION_OPERATORS = [:sum]

        def initialize(data, format:, first_column_label:, report_options:)
          self.data = data
          self.format = format
          self.first_column_label = first_column_label
          self.report_options = report_options || {}
        end

        def perform
          table_data
        end

        private

        def table_data
          data_rows_with_labels = data_rows.map.with_index do |data_row, index|
            label = format_string(data[:labels][index])
            [label] + data_row
          end
          [raw_column_names + aggregation_column_names] + data_rows_with_labels + aggregation_rows
        end

        def raw_column_names
          raw_column_names_column_values[0]
        end

        def raw_column_values
          raw_column_names_column_values[1]
        end

        def raw_data_rows
          @raw_data_rows ||= raw_column_values.transpose
        end

        def column_values
          raw_column_values + aggregation_column_values
        end

        def data_rows
          return raw_data_rows if aggregation_column_values.blank?
          raw_data_rows.zip(aggregation_column_values.transpose).map(&:flatten)
        end

        def raw_column_names_column_values
          @raw_column_names_column_values ||= begin
            column_names = [format_string(first_column_label)]
            column_values = []
            data[:datasets].each do |dataset|
              column_names << format_string(dataset[:label])
              column_values << dataset[:data]
            end
            [column_names, column_values]
          end
        end

        def aggregation_column_names
          row_aggregation_configs.map { |config| config[:label] }
        end

        def aggregation_column_values
          return [] if row_aggregation_configs.blank?
          row_aggregation_configs.map do |config|
            aggregate_array_of_arrays(raw_data_rows, config[:operator])
          end
        end

        def aggregation_rows
          return [] if column_aggregation_configs.blank?
          column_aggregation_configs.map do |config|
            [config[:label]] + aggregate_array_of_arrays(column_values, config[:operator])
          end
        end

        def aggregate_array_of_arrays(array_of_arrays, operator)
          operator = operator.try(:to_sym)
          raise ArgumentError.new("Invalid aggregation operator: #{operator}") unless operator.in?(VALID_AGGREGATION_OPERATORS)
          array_of_arrays.map do |values|
            if values.first.is_a?(Numeric)
              values.public_send(operator)
            else
              nil
            end
          end
        end

        def row_aggregation_configs
          return [] if report_options[:aggregations].blank?
          report_options[:aggregations].select { |config| config[:from] == 'rows' }
        end

        def column_aggregation_configs
          return [] if report_options[:aggregations].blank?
          report_options[:aggregations].select { |config| config[:from] == 'columns' }
        end

        def format_string(string)
          return string unless string && strip_html_tags?
          ActionView::Base.full_sanitizer.sanitize(string)
        end

        def strip_html_tags?
          format == 'csv'
        end
      end
    end
  end
end
