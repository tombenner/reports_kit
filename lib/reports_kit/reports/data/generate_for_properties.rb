module ReportsKit
  module Reports
    module Data
      class GenerateForProperties
        ROUND_PRECISION = 3

        attr_accessor :properties, :context_record

        def initialize(properties, context_record: nil)
          self.properties = properties.deep_symbolize_keys
          self.context_record = context_record
        end

        def perform
          if composite_operator
            raise ArgumentError.new('Aggregations require at least one measure') if all_measures.length == 0
            dimension_keys_values = Data::CompositeAggregation.new(properties, context_record: context_record).perform
            measures_dimension_keys_values = { CompositeMeasure.new(properties) => dimension_keys_values }
          elsif all_measures.length == 1 && composite_measures.length == 1
            dimension_keys_values = Data::CompositeAggregation.new(composite_measures.first.properties, context_record: context_record).perform
            measures_dimension_keys_values = { all_measures.first => dimension_keys_values }
          elsif all_measures.length == 1 && all_measures.first.dimensions.length == 2
            dimension_keys_values = Data::TwoDimensions.new(all_measures.first).perform
            measures_dimension_keys_values = { all_measures.first => dimension_keys_values }
            measures_dimension_keys_values = Data::PopulateTwoDimensions.new(measures_dimension_keys_values).perform
          elsif all_measures.length > 0
            measures_dimension_keys_values = measures_dimension_keys_values_for_one_dimension
          else
            raise ArgumentError.new('The configuration of measurse and dimensions is invalid')
          end

          measures_dimension_keys_values
        end

        private

        def composite_operator
          properties[:composite_operator]
        end

        def name
          properties[:name]
        end

        def measures_dimension_keys_values_for_one_dimension
          multi_dimension_measures_exist = all_measures.any? { |measure| measure.dimensions.length > 1 }
          raise ArgumentError.new('When more than one measures are configured, only one dimension may be used per measure') if multi_dimension_measures_exist

          measures_dimension_keys_values = all_measures.map do |measure|
            if measure.is_a?(CompositeMeasure)
              dimension_keys_values = Data::CompositeAggregation.new(measure.properties, context_record: context_record).perform
            else
              dimension_keys_values = Data::OneDimension.new(measure).perform
            end
            [measure, dimension_keys_values]
          end
          measures_dimension_keys_values = Hash[measures_dimension_keys_values]
          Data::PopulateOneDimension.new(measures_dimension_keys_values).perform
        end

        def all_measures
          @all_measures ||= Measure.new_from_properties!(properties, context_record: context_record)
        end

        def composite_measures
          @composite_measures ||= all_measures.grep(CompositeMeasure)
        end

        def measures
          @measures ||= all_measures.grep(Measure)
        end
      end
    end
  end
end
