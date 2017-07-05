module ReportsKit
  module Reports
    module Adapters
      class Mysql
        def self.truncate_to_day(column)
          "DATE(#{column})"
        end

        def self.truncate_to_week(column)
          "DATE_SUB(DATE(#{column}), INTERVAL DAYOFWEEK(#{column}) - 2 DAY)"
        end
      end
    end
  end
end
