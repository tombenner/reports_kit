module ReportsKit
  module Reports
    module FilterTypes
      class RecordDatetime < Base
        def apply_conditions(records)
          case criteria[:operator]
          when 'during'
            range_started_at = Time.now.utc.beginning_of_week(Rpt.config.first_day_of_week) - (criteria[:duration].to_i - 1).weeks
            evaluated_column = column.call(value)
            records.where("#{evaluated_column} IS NOT NULL").where("#{evaluated_column} > ?", range_started_at)
          else
            raise 'Unsupported'
          end
        end

        def valid?
          value.present? && criteria[:duration].present?
        end
      end
    end
  end
end
