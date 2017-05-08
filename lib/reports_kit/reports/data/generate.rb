module ReportsKit
  module Reports
    module Data
      class Generate
        ROUND_PRECISION = 3

        attr_accessor :properties, :context_record

        def initialize(properties, context_record: nil)
          self.properties = properties
          self.context_record = context_record
        end

        def perform
          measure_hash = properties[:measure]
          dimension_hashes = properties[:dimensions]
          raise ArgumentError.new('Blank dimensions') if dimension_hashes.blank?

          dimension_hashes = dimension_hashes.values if dimension_hashes.is_a?(Hash) && dimension_hashes.key?('0')

          raise ArgumentError.new('The number of measures must be exactly one') if measure_hash.blank?
          raise ArgumentError.new('The number of dimensions must be 1-2') unless dimension_hashes.length.in?([1, 2])

          measure = Measure.new(measure_hash, context_record: context_record)
          dimension = Dimension.new(dimension_hashes[0], measure: measure)
          second_dimension = Dimension.new(dimension_hashes[1], measure: measure) if dimension_hashes[1]

          if second_dimension
            data = Data::TwoDimensions.new(measure, dimension, second_dimension).perform
          else
            data = Data::OneDimension.new(measure, dimension).perform
          end
          data = data.merge(type: type)

          ChartOptions.new(data, properties[:chart]).perform
        end

        private

        def type
          properties[:type] || 'bar'
        end
      end
    end
  end
end
