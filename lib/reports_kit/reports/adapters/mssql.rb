module ReportsKit
  module Reports
    module Adapters
      class Mssql
        def self.truncate_to_day(column)
          "CONVERT(date,#{column})"
        end

        def self.truncate_to_week(column)
          case ReportsKit.configuration.first_day_of_week
          when :sunday
            "DATEADD(day, 1 - DATEPART(weekday,#{column}), CONVERT(date,#{column}))"
          when :monday
            "DATEADD(day,  - (DATEPART(weekday,#{column}) + 5 ) %  7, CONVERT(date,#{column}))"
          else
            raise ArgumentError.new("Unsupported first_day_of_week: #{ReportsKit.configuration.first_day_of_week}")
          end
        end

        def self.truncate_to_month(column)
          "DATEADD(day, 1 - DATEPART(day,#{column}),  CONVERT(date,#{column}))"
        end
      end
    end
  end
end
