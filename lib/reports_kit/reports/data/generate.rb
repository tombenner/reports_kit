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
          if measures.length == 1 && measures.first.dimensions.length == 2
            data = Data::TwoDimensions.new(measures.first).perform
          elsif measures.length > 0
            raise ArgumentError.new('When more than one measures are configured, only one dimension may be used per measure') if measures.any? { |measure| measure.dimensions.length > 1 }
            data = Data::OneDimension.new(measures).perform
          else
            raise ArgumentError.new('The configuration of measurse and dimensions is invalid')
          end

          ChartOptions.new(data, options: properties[:chart], inferred_options: inferred_options).perform
        end

        private

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
          @measures ||= begin
            measure_hashes = [properties[:measure]].compact + Array(properties[:measures])
            raise ArgumentError.new('At least one measure must be configured') if measure_hashes.blank?
            measure_hashes.map do |measure_hash|
              Measure.new(measure_hash, context_record: context_record)
            end
          end
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
