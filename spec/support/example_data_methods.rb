class ExampleDataMethods
  def self.issues_by_opened_at(properties)
    Issue.group_by_week(:opened_at).count.map { |date, count| [format_date(date), count] }
  end

  def self.issues_by_opened_at_and_repo(properties)
    Issue.group_by_week(:opened_at).joins(:repo).group('repos.full_name').count.map do |(date, name), count|
      [[format_date(date), name], count]
    end
  end

  def self.issues_by_opened_at_with_filters(properties)
    ui_filters = properties[:ui_filters]
    issues = Issue.group_by_week(:opened_at)
    issues = issues.where(state: ui_filters[:state]) if ui_filters.try(:[], :state).present?
    issues.count.map { |date, count| [format_date(date), count] }
  end

  def self.format_date(date)
    date.strftime('%b %-d, \'%y')
  end
end
