module ReportsKit
  module Reports
    module FilterTypes
      class Boolean < Base
        def apply_conditions
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
      end
    end
  end
end
