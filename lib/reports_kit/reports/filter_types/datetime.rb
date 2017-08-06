module ReportsKit
  module Reports
    module FilterTypes
      class Datetime < Base
        DEFAULT_CRITERIA = {
          operator: 'between'
        }
        SEPARATOR = ' - '

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
            return unless valid?
            start_string, end_string = value.split(SEPARATOR)
            start_at = ReportsKit::Reports::Data::Utils.parse_date_string(start_string)
            end_at = ReportsKit::Reports::Data::Utils.parse_date_string(end_string)
            adjust_range_to_dimension(start_at, end_at)
          end
        end

        def start_at
          start_at_end_at.try(:[], 0)
        end

        def end_at
          start_at_end_at.try(:[], 1)
        end

        def adjust_range_to_dimension(start_at, end_at)
          return [start_at, end_at] unless primary_dimension.configured_by_time?
          return [start_at.beginning_of_day, end_at.end_of_day] if primary_dimension.granularity == 'day'
          return [
            start_at.beginning_of_week(ReportsKit.configuration.first_day_of_week),
            end_at.end_of_week(ReportsKit.configuration.first_day_of_week)
          ] if primary_dimension.granularity == 'week'
          [start_at, end_at]
        end

        def valid?
          value.present?
        end
      end
    end
  end
end
