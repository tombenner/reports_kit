module ReportsKit
  module Reports
    module Data
      class Generate
        ROUND_PRECISION = 3

        attr_accessor :properties, :context_record

        def initialize(properties, context_record: nil)
          self.properties = properties.deep_symbolize_keys
          self.context_record = context_record
        end

        def perform
          if second_dimension
            data = Data::TwoDimensions.new(measure, dimension, second_dimension).perform
          else
            data = Data::OneDimension.new(measure, dimension).perform
          end

          ChartOptions.new(data, options: properties[:chart], inferred_options: inferred_options).perform
        end

        private

        def measure
          @measure ||= begin
            measure_hash = properties[:measure]
            raise ArgumentError.new('The number of measures must be exactly one') if measure_hash.blank?
            Measure.new(measure_hash, context_record: context_record)
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
            y_axis_label: measure.label
          }
        end
      end
    end
  end
end
