module ReportsKit
  class ReportBuilder
    include ActionView::Helpers

    RELATIVE_DATE_OPTIONS = [
      {
        name: 'All time',
        string: '',
        value: nil
      },
      {
        name: '1 week ago',
        string: '-1w',
        value: 1.week
      },
      {
        name: '1 month ago',
        string: '-1mo',
        value: 1.month
      },
      {
        name: '1 year ago',
        string: '-1y',
        value: 1.year
      },
    ]

    attr_accessor :properties

    def initialize(properties)
      self.properties = properties
    end

    def relative_date(filter_key)
      options = RELATIVE_DATE_OPTIONS.map { |option| [option[:name], option[:string]] }
      selected = nil
      select_tag(filter_key, options_for_select(options, selected), class: 'form-control input-sm')
    end
  end
end
