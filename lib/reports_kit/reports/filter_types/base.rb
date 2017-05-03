module ReportsKit
  module Reports
    module FilterTypes
      class Base
        attr_accessor :records, :properties

        def initialize(records, properties)
          self.records = records
          self.properties = properties
        end

        def apply_filter
          self.records = records.joins(joins) if joins.present?
          if value.blank? && !is_a?(FilterTypes::Boolean)
            return records
          end
          apply_conditions
        end

        private

        def apply_conditions
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
