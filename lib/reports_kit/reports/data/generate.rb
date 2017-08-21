module ReportsKit
  module Reports
    module Data
      class Generate
        ROUND_PRECISION = 3

        attr_accessor :properties, :context_record

        def initialize(properties, context_record: nil)
          self.properties = properties.deep_symbolize_keys
          self.properties = ReportsKit.configuration.default_properties.deep_merge(self.properties) if ReportsKit.configuration.default_properties
          self.properties = Utils.normalize_properties(self.properties)
          self.context_record = context_record
        end

        def perform
          data = ReportsKit::Cache.get(properties, context_record)
          return data.deep_symbolize_keys if data

          if two_dimensions?
            raw_data = Data::FormatTwoDimensions.new(serieses.first, serieses_results.first.last, order: order, limit: limit).perform
          else
            raw_data = Data::FormatOneDimension.new(serieses_results, order: order, limit: limit).perform
          end
          raw_data = format_csv_times(raw_data) if format == 'csv'
          raw_data = Data::AddTableAggregations.new(raw_data, report_options: report_options).perform if table_or_csv?
          raw_data = data_format_method.call(data: raw_data, properties: properties, context_record: context_record) if data_format_method
          raw_data = csv_data_format_method.call(data: raw_data, properties: properties, context_record: context_record) if csv_data_format_method && format == 'csv'
          chart_data = format_chart_data(raw_data)

          data = { chart_data: chart_data }
          data = ChartOptions.new(data, options: properties[:chart], inferred_options: inferred_options).perform
          data[:report_options] = report_options if report_options
          data = format_table_data(data) if table_or_csv?
          ReportsKit::Cache.set(properties, context_record, data)
          data
        end

        private

        def format_chart_data(raw_data)
          chart_data = {}
          chart_data[:labels] = raw_data[:entities].map(&:label)
          chart_data[:datasets] = raw_data[:datasets].map do |raw_dataset|
            {
              label: raw_dataset[:entity].label,
              data: raw_dataset[:values].map(&:formatted)
            }
          end
          chart_data
        end

        def format_table_data(data)
          data[:table_data] = Data::FormatTable.new(
            data.delete(:chart_data),
            format: format,
            first_column_label: primary_dimension.label,
            report_options: report_options
          ).perform
          data[:type] = format
          data
        end

        def serieses_results
          @serieses_results ||= GenerateForProperties.new(properties, context_record: context_record).perform
        end

        def two_dimensions?
          dimension_keys = serieses_results.first.last.keys
          dimension_keys.first.is_a?(Array)
        end

        def order
          @order ||= begin
            return Order.parse(properties[:order]) if properties[:order].present?
            inferred_order
          end
        end

        def limit
          properties[:limit]
        end

        def inferred_order
          return Order.new('dimension1', nil, 'asc') if primary_dimension.configured_by_time?
          Order.new('count', nil, 'desc')
        end

        def serieses
          @serieses ||= Series.new_from_properties!(properties, context_record: context_record)
        end

        def report_options
          report_options = properties[:report_options] || {}
          head_rows_count = report_options[:head_rows_count]
          foot_rows_count = report_options[:foot_rows_count]
          foot_rows_count ||= report_options[:aggregations].count { |config| config[:from] == 'rows' } if report_options[:aggregations]

          report_options[:head_rows_count] = head_rows_count if head_rows_count && head_rows_count > 0
          report_options[:foot_rows_count] = foot_rows_count if foot_rows_count && foot_rows_count > 0
          report_options.presence
        end

        def data_format_method
          ReportsKit.configuration.custom_method(report_options.try(:[], :data_format_method))
        end

        def csv_data_format_method
          ReportsKit.configuration.custom_method(report_options.try(:[], :csv_data_format_method))
        end

        def format
          properties[:format]
        end

        def format_csv_times(raw_data)
          return raw_data unless primary_dimension.configured_by_time?
          raw_data[:entities] = raw_data[:entities].map do |entity|
            entity.label = Utils.format_csv_time(entity.instance)
            entity
          end
          raw_data
        end

        def primary_dimension
          serieses.first.dimensions.first
        end

        def table_or_csv?
          format.in?(%w(table csv))
        end

        def inferred_options
          {
            x_axis_label: primary_dimension.label,
            y_axis_label: serieses.length == 1 ? serieses.first.label : nil
          }
        end
      end
    end
  end
end
