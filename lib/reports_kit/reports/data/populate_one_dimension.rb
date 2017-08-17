module ReportsKit
  module Reports
    module Data
      class PopulateOneDimension
        attr_accessor :sparse_serieses_dimension_keys_values, :context_record, :properties

        def initialize(sparse_serieses_dimension_keys_values, context_record: nil, properties: nil)
          self.sparse_serieses_dimension_keys_values = sparse_serieses_dimension_keys_values
          self.context_record = context_record
          self.properties = properties
        end

        def perform
          return sparse_serieses_dimension_keys_values if sparse_serieses_dimension_keys_values.length == 1
          serieses_dimension_keys_values
        end

        private

        def serieses_dimension_keys_values
          serieses_dimension_keys_values = sparse_serieses_dimension_keys_values.map do |series, dimension_keys_values|
            dimension_keys.each do |key|
              dimension_keys_values[key] ||= 0
            end
            [series, dimension_keys_values]
          end
          Hash[serieses_dimension_keys_values]
        end

        def dimension_keys
          dimension_keys_from_edit_dimension_keys_method || dimension_keys_from_results
        end

        def dimension_keys_from_edit_dimension_keys_method
          return unless edit_dimension_keys_method
          edit_dimension_keys_method.call(dimension_keys: dimension_keys_from_results, properties: properties, context_record: context_record)
        end

        def dimension_keys_from_results
          @dimension_keys_from_results ||= begin
            sparse_serieses_dimension_keys_values.map do |series, dimension_keys_values|
              dimension_keys_values.keys
            end.reduce(&:+).uniq
          end
        end

        def edit_dimension_keys_method
          return unless properties
          ReportsKit.configuration.custom_method(properties[:report_options].try(:[], :edit_dimension_keys_method))
        end
      end
    end
  end
end
