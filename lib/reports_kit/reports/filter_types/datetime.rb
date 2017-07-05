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
            records.where("#{column} IS NOT NULL").where("#{column} BETWEEN ? AND ?", start_at, end_at)
          else
            raise ArgumentError.new("Unsupported operator: '#{criteria[:operator]}'")
          end
        end

        def start_at_end_at
          @start_at_end_at ||= begin
            start_string, end_string = value.split(' - ')
            start_at = Date.parse(start_string)
            end_at = Date.parse(end_string)
            [start_at, end_at]
          end
        end

        def start_at
          start_at_end_at[0]
        end

        def end_at
          start_at_end_at[1]
        end

        def valid?
          value.present?
        end
      end
    end
  end
end
