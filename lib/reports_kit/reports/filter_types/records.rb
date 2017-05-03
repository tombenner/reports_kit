module ReportsKit
  module Reports
    module FilterTypes
      class Records < Base
        def apply_conditions
          case criteria[:operator]
          when 'include'
            records.where(column => value)
          when 'does_not_include'
            records.where.not(column => value)
          else
            raise 'Unsupported'
          end
        end

        def valid?
          value.present?
        end
      end
    end
  end
end
