module ReportsKit
  module Reports
    module Adapters
      class Postgresql
        def self.truncate_to_day(column)
          "#{column}::date"
        end

        def self.truncate_to_week(column)
          "DATE_TRUNC('week', #{column}::timestamp)"
        end
      end
    end
  end
end
