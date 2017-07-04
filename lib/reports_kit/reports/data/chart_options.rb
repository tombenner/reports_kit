module ReportsKit
  module Reports
    module Data
      class ChartOptions
        DEFAULT_COLORS = %w(
          #1f77b4
          #aec7e8
          #ff7f0e
          #ffbb78
          #2ca02c
          #98df8a
          #d62728
          #ff9896
          #9467bd
          #c5b0d5
          #8c564b
          #c49c94
          #e377c2
          #f7b6d2
          #7f7f7f
          #c7c7c7
          #bcbd22
          #dbdb8d
          #17becf
          #9edae5
        ).freeze
        DEFAULT_OPTIONS = {
          scales: {
            xAxes: [{
              gridLines: {
                display: false
              },
              barPercentage: 0.9,
              categoryPercentage: 0.9
            }],
            yAxes: [{
              ticks: {
                beginAtZero: true
              }
            }]
          },
          legend: {
            labels: {
              usePointStyle: true
            }
          },
          maintainAspectRatio: false,
          tooltips: {
            xPadding: 8,
            yPadding: 7
          }
        }.freeze

        attr_accessor :data, :options, :chart_options, :inferred_options, :dataset_options, :type

        def initialize(data, options:, inferred_options: {})
          self.data = data
          self.options = options.try(:except, :options) || {}
          self.chart_options = options.try(:[], :options) || {}
          self.dataset_options = options.try(:[], :datasets)
          self.type = options.try(:[], :type) || 'bar'

          self.options = inferred_options.deep_merge(self.options) if inferred_options.present?
        end

        def perform
          set_colors
          set_chart_options
          set_dataset_options
          set_type
          data
        end

        private

        def set_colors
          if donut_or_pie_chart?
            set_record_scoped_colors
          else
            set_dataset_scoped_colors
          end
        end

        def set_record_scoped_colors
          self.data[:chart_data][:datasets] = self.data[:chart_data][:datasets].map do |dataset|
            length = dataset[:data].length
            dataset[:backgroundColor] = DEFAULT_COLORS * (length.to_f / DEFAULT_COLORS.length).ceil
            dataset
          end
        end

        def set_dataset_scoped_colors
          self.data[:chart_data][:datasets] = data[:chart_data][:datasets].map.with_index do |dataset, index|
            color = DEFAULT_COLORS[index % DEFAULT_COLORS.length]
            dataset[:backgroundColor] = color
            dataset[:borderColor] = color
            dataset
          end
        end

        def default_options
          @default_options ||= begin
            return {} if donut_or_pie_chart?

            default_options = DEFAULT_OPTIONS.deep_dup

            x_axis_label = options[:x_axis_label]
            if x_axis_label
              default_options[:scales] ||= {}
              default_options[:scales][:xAxes] ||= []
              default_options[:scales][:xAxes][0] ||= {}
              default_options[:scales][:xAxes][0][:scaleLabel] ||= {}
              default_options[:scales][:xAxes][0][:scaleLabel][:display] ||= true
              default_options[:scales][:xAxes][0][:scaleLabel][:labelString] ||= x_axis_label
            end

            y_axis_label = options[:y_axis_label]
            if y_axis_label
              default_options[:scales] ||= {}
              default_options[:scales][:yAxes] ||= []
              default_options[:scales][:yAxes][0] ||= {}
              default_options[:scales][:yAxes][0][:scaleLabel] ||= {}
              default_options[:scales][:yAxes][0][:scaleLabel][:display] ||= true
              default_options[:scales][:yAxes][0][:scaleLabel][:labelString] ||= y_axis_label
            end

            default_options
          end
        end

        def set_chart_options
          merged_options = default_options
          merged_options = merged_options.deep_merge(chart_options) if chart_options
          self.data[:chart_data][:options] = merged_options
        end

        def set_dataset_options
          return if self.data[:chart_data][:datasets].blank? || dataset_options.blank?
          self.data[:chart_data][:datasets] = self.data[:chart_data][:datasets].map do |dataset|
            dataset.merge(dataset_options)
          end
        end

        def set_type
          return if type.blank?
          self.data[:type] = type
        end

        def donut_or_pie_chart?
          type.in?(%w(donut pie))
        end
      end
    end
  end
end
