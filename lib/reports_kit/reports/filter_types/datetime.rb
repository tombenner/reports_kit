module ReportsKit
  module Reports
    module FilterTypes
      class Datetime < Base
        FIRST_DAY_OF_WEEK = :sunday
        RELATIVE_DATE_OPTIONS = [
          { name: 'All time', string: '', value: nil },
          { name: '1 week ago', string: '-1w', value: 1.week },
          { name: '2 weeks ago', string: '-2w', value: 2.weeks },
          { name: '1 month ago', string: '-1mo', value: 1.month },
          { name: '2 months ago', string: '-2mo', value: 2.months },
          { name: '3 months ago', string: '-3mo', value: 3.months },
          { name: '4 months ago', string: '-4mo', value: 4.months },
          { name: '6 months ago', string: '-6mo', value: 6.months },
          { name: '1 year ago', string: '-1y', value: 1.year }
        ]
        DEFAULT_CRITERIA = {
          operator: 'during',
          value: '-6mo'
        }

        def apply_conditions(records)
          case criteria[:operator]
          when 'during'
            now = Time.now.utc
            if value_duration == 0
              start_at = now.beginning_of_week(FIRST_DAY_OF_WEEK)
              end_at = start_at + 1.week
              records.where("#{column} IS NOT NULL").where("#{column} BETWEEN ? AND ?", start_at, end_at)
            elsif value_duration > 0
              start_at = now.beginning_of_week(FIRST_DAY_OF_WEEK) - value_duration + 1.week
              records.where("#{column} IS NOT NULL").where("#{column} BETWEEN ? AND ?", start_at, now)
            elsif value_duration < 0
              start_at = now
              end_at = now.beginning_of_week(FIRST_DAY_OF_WEEK) - value_duration + 1.week
              records.where("#{column} IS NOT NULL").where("#{column} BETWEEN ? AND ?", start_at, end_at)
            end
          else
            raise 'Unsupported'
          end
        end

        def valid?
          value.present?
        end

        private

        def value_duration
          @value_duration ||= begin
            option = RELATIVE_DATE_OPTIONS.find { |option| option[:string] == value }
            raise ArgumentError.new("Invalid Datetime value: #{value}") unless option
            option[:value]
          end
        end
      end
    end
  end
end
