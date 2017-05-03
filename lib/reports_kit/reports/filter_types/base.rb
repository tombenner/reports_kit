module ReportsKit
  module Reports
    module FilterTypes
      class Base
        attr_accessor :properties

        def initialize(properties)
          self.properties = properties
        end

        def apply_filter(records)
          return records unless valid?
          records = records.joins(joins) if joins.present?
          if value.blank? && !is_a?(FilterTypes::Boolean)
            return records
          end
          apply_conditions(records)
        end

        def default_criteria
          self.class::DEFAULT_CRITERIA
        end

        private

        def apply_conditions(records)
          raise NotImplementedError
        end

        def criteria
          properties[:criteria]
        end

        def value
          criteria[:value]
        end

        def joins
          properties[:joins]
        end

        def column
          properties[:key]
        end
      end
    end
  end
end
