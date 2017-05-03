module ReportsKit
  class ReportBuilder
    include ActionView::Helpers

    attr_accessor :properties

    def initialize(properties)
      self.properties = properties.deep_symbolize_keys
    end

    def relative_date(filter_key)
      filter_key = filter_key.to_s
      options = Reports::FilterTypes::Datetime::RELATIVE_DATE_OPTIONS.map { |option| [option[:name], option[:string]] }
      filter = measure_filters.find { |filter| filter[:key] == filter_key }
      selected = filter[:criteria][:value] if filter
      select_tag(filter_key, options_for_select(options, selected), class: 'form-control input-sm')
    end

    private

    def measure_filters
      properties[:measure][:filters] || []
    end
  end
end
