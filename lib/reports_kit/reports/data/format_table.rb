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
          [column_names] + data_rows_with_labels
        end

        def column_names
          column_names_column_values[0]
        end

        def column_values
          column_names_column_values[1]
        end

        def data_rows
          @data_rows ||= column_values.transpose
        end

        def column_names_column_values
          @column_names_column_values ||= begin
            column_names = [format_string(first_column_label)]
            column_values = []
            data[:datasets].each do |dataset|
              column_names << format_string(dataset[:label])
              column_values << dataset[:data]
            end
            [column_names, column_values]
          end
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
