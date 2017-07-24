module ReportsKit
  module Reports
    module FilterTypes
      class Boolean < Base
        DEFAULT_CRITERIA = {
          value: nil
        }

        def apply_conditions(records)
          case conditions
          when ::String
            records.where("(#{conditions}) #{sql_operator} true")
          when ::Hash
            boolean_value ? records.where(conditions) : records.not.where(conditions)
          when ::Proc
            conditions.call(records)
          else
            raise ArgumentError.new("Unsupported conditions type: '#{conditions}'")
          end
        end

        def boolean_value
          case criteria[:value]
          when true, 'true'
            true
          when false, 'false'
            false
          else
            raise ArgumentError.new("Unsupported value: '#{criteria[:value]}'")
          end
        end

        def sql_operator
          boolean_value ? '=' : '!='
        end

        def valid?
          criteria[:value].present?
        end

        def conditions
          settings[:conditions] || properties[:key]
        end
      end
    end
  end
end
