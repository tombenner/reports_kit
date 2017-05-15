module ReportsKit
  module Reports
    module FilterTypes
      class Datetime < Base
        DEFAULT_CRITERIA = {
          operator: 'between'
        }

        def apply_conditions(records)
          case criteria[:operator]
          when 'between'
            start_string, end_string = value.split(' - ')
            start_at = Date.parse(start_string)
            end_at = Date.parse(end_string)
            records.where("#{column} IS NOT NULL").where("#{column} BETWEEN ? AND ?", start_at, end_at)
          else
            raise ArgumentError.new("Unsupported operator: '#{criteria[:operator]}'")
          end
        end

        def valid?
          value.present?
        end
      end
    end
  end
end
