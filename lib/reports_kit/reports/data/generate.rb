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
          if second_dimension
            raise ArgumentError.new('When two dimensions are configured, only one measure is supported') if measures.length > 1
            data = Data::TwoDimensions.new(measures.first, dimension, second_dimension).perform
          else
            data = Data::OneDimension.new(measures, dimension).perform
          end

          ChartOptions.new(data, options: properties[:chart], inferred_options: inferred_options).perform
        end

        private

        def apply_ui_filters
          return if properties[:ui_filters].blank?
          self.properties[:measures] = properties[:measures].map do |measure_properties|
            measure_properties[:filters] = measure_properties[:filters].map do |filter_properties|
              key = filter_properties[:key]
              value = properties[:ui_filters][key.to_sym]
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
          @measures ||= begin
            measure_hashes = [properties[:measure]].compact + Array(properties[:measures])
            raise ArgumentError.new('At least one measure must be configured') if measure_hashes.blank?
            measure_hashes.map do |measure_hash|
              Measure.new(measure_hash, context_record: context_record)
            end
          end
        end

        def dimension
          @dimension ||= begin
            Dimension.new(dimension_hashes[0])
          end
        end

        def second_dimension
          @second_dimension ||= begin
            Dimension.new(dimension_hashes[1]) if dimension_hashes[1]
          end
        end

        def dimension_hashes
          @dimension_hashes ||= begin
            dimension_hashes = properties[:dimensions]
            raise ArgumentError.new('Blank dimensions') if dimension_hashes.blank?
            raise ArgumentError.new('The number of dimensions must be 1-2') unless dimension_hashes.length.in?([1, 2])
            dimension_hashes = dimension_hashes.values if dimension_hashes.is_a?(Hash) && dimension_hashes.key?(:'0')
            dimension_hashes
          end
        end

        def inferred_options
          {
            x_axis_label: dimension.label,
            y_axis_label: measures.length == 1 ? measures.first.label : nil
          }
        end
      end
    end
  end
end
