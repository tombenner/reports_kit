module ReportsKit
  module Reports
    module Adapters
      class Postgresql
        def self.truncate_to_day(column)
          "#{column}::date"
        end

        def self.truncate_to_week(column)
          case ReportsKit.configuration.first_day_of_week
          when :sunday
            "DATE_TRUNC('week', #{column}::timestamp + '1 day'::interval) - '1 day'::interval"
          when :monday
            "DATE_TRUNC('week', #{column}::timestamp)"
          else
            raise ArgumentError.new("Unsupported first_day_of_week: #{ReportsKit.configuration.first_day_of_week}")
          end
        end
      end
    end
  end
end
