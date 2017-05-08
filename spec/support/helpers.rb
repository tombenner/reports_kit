module Helpers
  def now
    Time.zone.now
  end

  def date_string_for_filter(time)
    time.strftime('%b %-d, %Y')
  end

  def format_time(week_offset)
    ReportsKit::Reports::Data::Utils.format_time((now - week_offset.weeks).beginning_of_week)
  end
end
