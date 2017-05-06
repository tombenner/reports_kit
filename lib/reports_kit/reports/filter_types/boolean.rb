module ReportsKit
  module Reports
    module FilterTypes
      class Boolean < Base
        DEFAULT_CRITERIA = {
          operator: nil
        }

        def apply_conditions(records)
          case criteria[:operator]
          when 'true'
            records.where("(#{column}) = true")
          when 'false'
            records.where("(#{column}) != true")
          else
            raise "Unsupported: #{criteria[:operator]}"
          end
        end

        def valid?
          criteria[:operator].present?
        end

        def column
          settings[:conditions] || properties[:key]
        end
      end
    end
  end
end
