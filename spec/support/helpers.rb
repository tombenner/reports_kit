module Helpers
  def now
    Time.zone.now
  end

  def date_string_for_filter(time)
    time.strftime('%b %-d, %Y')
  end

  def week_offset_timestamp(week_offset)
    (now - week_offset.weeks).beginning_of_week.to_i * 1000
  end
end
