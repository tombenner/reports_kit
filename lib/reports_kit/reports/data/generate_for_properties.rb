module ReportsKit
  module Reports
    module Data
      class GenerateForProperties
        ROUND_PRECISION = 3

        attr_accessor :properties, :context_record

        def initialize(properties, context_record: nil)
          self.properties = properties.deep_symbolize_keys
          apply_ui_filters
          self.context_record = context_record
        end

        def perform
          if aggregation
            raise ArgumentError.new('Aggregations require at least one measure') if measures.length == 0
            measures_dimension_keys_values = Data::Aggregation.new(properties, measures).perform
          elsif measures.length == 1 && measures.first.dimensions.length == 2
            dimension_keys_values = Data::TwoDimensions.new(measures.first).perform
            measures_dimension_keys_values = { measures.first => dimension_keys_values }
          elsif measures.length > 0
            raise ArgumentError.new('When more than one measures are configured, only one dimension may be used per measure') if measures.any? { |measure| measure.dimensions.length > 1 }
            measures_dimension_keys_values = Hash[measures.map { |measure| [measure, Data::OneDimension.new(measure).perform] }]
            measures_dimension_keys_values = Data::PopulateOneDimension.new(measures_dimension_keys_values).perform
          else
            raise ArgumentError.new('The configuration of measurse and dimensions is invalid')
          end

          measures_dimension_keys_values
        end

        private

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

        def all_measures
          @all_measures ||= begin
            measure_hashes = [properties[:measure]].compact + Array(properties[:measures])
            raise ArgumentError.new('At least one measure must be configured') if measure_hashes.blank?
            measure_hashes.map do |measure_hash|
              if measure_hash[:aggregation].present?
                AggregationMeasure.new(measure_hash)
              else
                Measure.new(measure_hash, context_record: context_record)
              end
            end
          end
        end

        def measures
          @measures ||= all_measures.grep(Measure)
        end

        def format_number(number)
          number_i = number.to_i
          return number_i if number == number_i
          number
        end
      end
    end
  end
end
