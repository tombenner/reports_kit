module ReportsKit
  module Reports
    module FilterTypes
      class Boolean < Base
        DEFAULT_CRITERIA = {
          operator: nil
        }

        def apply_conditions(records)
          case conditions
          when ::String
            records.where("(#{conditions}) #{sql_operator} true")
          when ::Hash
            boolean_operator ? records.where(conditions) : records.not.where(conditions)
          else
            raise ArgumentError.new("Unsupported conditions type: '#{conditions}'")
          end
        end

        def boolean_operator
          case criteria[:operator]
          when true, 'true'
            true
          when false, 'false'
            false
          else
            raise ArgumentError.new("Unsupported operator: '#{criteria[:operator]}'")
          end
        end

        def sql_operator
          boolean_operator ? '=' : '!='
        end

        def valid?
          criteria[:operator].present?
        end

        def conditions
          settings[:conditions] || properties[:key]
        end
      end
    end
  end
end
