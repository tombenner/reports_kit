module ReportsKit
  module Reports
    module Data
      class Generate
        ROUND_PRECISION = 3

        attr_accessor :properties, :context_record

        def initialize(properties, context_record: nil)
          self.properties = properties.deep_symbolize_keys
          apply_ui_filters
          self.context_record = context_record
        end

        def perform
          if two_dimensions?
            chart_data = Data::FormatTwoDimensions.new(measures.first, measures_results.first.last).perform
          else
            chart_data = Data::FormatOneDimension.new(measures_results).perform
          end

          data = { chart_data: chart_data }
          data = ChartOptions.new(data, options: properties[:chart], inferred_options: inferred_options).perform
          if format == 'table'
            data[:table_data] = format_table(data.delete(:chart_data))
            data[:type] = format
          end
          data
        end

        private

        def measures_results
          @measures_results ||= GenerateForProperties.new(properties, context_record: context_record).perform
        end

        def two_dimensions?
          dimension_keys = measures_results.first.last.keys
          dimension_keys.first.is_a?(Array)
        end

        def aggregation
          properties[:aggregation]
        end

        def name
          properties[:name]
        end

        def apply_ui_filters
          return if properties[:ui_filters].blank?
          self.properties[:measures] = properties[:measures].map do |measure_properties|
            measure_properties[:filters] = measure_properties[:filters].map do |filter_properties|
              key = filter_properties[:key]
              ui_key = filter_properties[:ui_key]
              value = properties[:ui_filters][key.to_sym]
              value ||= properties[:ui_filters][ui_key.to_sym] if ui_key
              if value
                criteria_key = value.in?([true, false]) ? :operator : :value
                filter_properties[:criteria][criteria_key] = value
              end
              filter_properties
            end
            measure_properties
          end
        end

        def measures
          @measures ||= Measure.new_from_properties!(properties, context_record: context_record)
        end

        def format
          properties[:format]
        end

        def format_table(data)
          column_names = [nil]
          column_values = []
          data[:datasets].each do |dataset|
            column_names << dataset[:label]
            column_values << dataset[:data].map { |number| format_number(number) }
          end
          rows = column_values.transpose
          rows = rows.map.with_index do |row, index|
            label = data[:labels][index]
            row.unshift(label)
          end
          [column_names] + rows
        end

        def format_number(number)
          number_i = number.to_i
          return number_i if number == number_i
          number
        end

        def inferred_options
          {
            x_axis_label: measures.first.dimensions.first.label,
            y_axis_label: measures.length == 1 ? measures.first.label : nil
          }
        end
      end
    end
  end
end
