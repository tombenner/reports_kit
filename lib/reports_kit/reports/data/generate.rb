module ReportsKit
  module Reports
    module Data
      class Generate
        ROUND_PRECISION = 3

        attr_accessor :properties, :context_record

        def initialize(properties, context_record: nil)
          self.properties = properties.deep_symbolize_keys
          self.properties = Utils.apply_ui_filters(self.properties)
          self.context_record = context_record
        end

        def perform
          data = ReportsKit::Cache.get(properties, context_record)
          return data if data

          if two_dimensions?
            chart_data = Data::FormatTwoDimensions.new(measures.first, measures_results.first.last, order: order).perform
          else
            chart_data = Data::FormatOneDimension.new(measures_results, order: order).perform
          end

          data = { chart_data: chart_data }
          data = ChartOptions.new(data, options: properties[:chart], inferred_options: inferred_options).perform
          if format == 'table'
            data[:table_data] = format_table(data.delete(:chart_data))
            data[:type] = format
          end
          ReportsKit::Cache.set(properties, context_record, data)
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

        def order
          @order ||= begin
            return Order.parse(properties[:order]) if properties[:order].present?
            inferred_order
          end
        end

        def inferred_order
          return Order.new('dimension1', nil, 'asc') if primary_dimension.configured_by_time?
          Order.new('count', nil, 'desc')
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
            column_values << dataset[:data]
          end
          rows = column_values.transpose
          rows = rows.map.with_index do |row, index|
            label = data[:labels][index]
            row.unshift(label)
          end
          [column_names] + rows
        end

        def primary_dimension
          measures.first.dimensions.first
        end

        def inferred_options
          {
            x_axis_label: primary_dimension.label,
            y_axis_label: measures.length == 1 ? measures.first.label : nil
          }
        end
      end
    end
  end
end
