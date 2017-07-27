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
            raise ArgumentError.new('Aggregations require at least one series') if all_serieses.length == 0
            dimension_keys_values = Data::AggregateComposite.new(properties, context_record: context_record).perform
            serieses_dimension_keys_values = { CompositeSeries.new(properties) => dimension_keys_values }
          elsif all_serieses.length == 1 && composite_serieses.length == 1
            dimension_keys_values = Data::AggregateComposite.new(composite_serieses.first.properties, context_record: context_record).perform
            serieses_dimension_keys_values = { all_serieses.first => dimension_keys_values }
          elsif all_serieses.length == 1 && all_serieses.first.dimensions.length == 2
            dimension_keys_values = Data::AggregateTwoDimensions.new(all_serieses.first).perform
            serieses_dimension_keys_values = { all_serieses.first => dimension_keys_values }
            serieses_dimension_keys_values = Data::PopulateTwoDimensions.new(serieses_dimension_keys_values).perform
          elsif all_serieses.length > 0
            serieses_dimension_keys_values = serieses_dimension_keys_values_for_one_dimension
          else
            raise ArgumentError.new('The configuration of measurse and dimensions is invalid')
          end

          serieses_dimension_keys_values
        end

        private

        def composite_operator
          properties[:composite_operator]
        end

        def name
          properties[:name]
        end

        def serieses_dimension_keys_values_for_one_dimension
          multi_dimension_serieses_exist = all_serieses.any? { |series| series.dimensions.length > 1 }
          raise ArgumentError.new('When more than one series are configured, only one dimension may be used per series') if multi_dimension_serieses_exist

          serieses_dimension_keys_values = all_serieses.map do |series|
            if series.is_a?(CompositeSeries)
              dimension_keys_values = Data::AggregateComposite.new(series.properties, context_record: context_record).perform
            else
              dimension_keys_values = Data::AggregateOneDimension.new(series).perform
            end
            [series, dimension_keys_values]
          end
          serieses_dimension_keys_values = Hash[serieses_dimension_keys_values]
          Data::PopulateOneDimension.new(serieses_dimension_keys_values).perform
        end

        def all_serieses
          @all_serieses ||= Series.new_from_properties!(properties, context_record: context_record)
        end

        def composite_serieses
          @composite_serieses ||= all_serieses.grep(CompositeSeries)
        end

        def serieses
          @serieses ||= all_serieses.grep(Series)
        end
      end
    end
  end
end
