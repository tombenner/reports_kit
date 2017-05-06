module ReportsKit
  module Reports
    module FilterTypes
      class Base
        attr_accessor :settings, :properties

        def initialize(settings, properties)
          self.settings = settings || {}
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
          settings[:joins]
        end

        def column
          settings[:column] || properties[:key]
        end
      end
    end
  end
end
