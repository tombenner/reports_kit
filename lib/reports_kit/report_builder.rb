module ReportsKit
  class ReportBuilder
    include ActionView::Helpers

    attr_accessor :properties

    def initialize(properties)
      self.properties = properties.deep_symbolize_keys
    end

    def multi_autocomplete(filter_key, placeholder: nil)
      filter_key = filter_key.to_s
      filter = measure_filters.find { |filter| filter[:key] == filter_key }
      selected = filter[:criteria][:value] if filter && filter[:criteria]
      # TODO: Don't hardcode path
      select_tag(filter_key, nil, class: 'form-control input-sm select2', multiple: 'multiple', data: { placeholder: placeholder, path: "/reports_kit/resources/measures/#{measure_key}/filters/#{filter_key}/autocomplete" })
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

    def measure_key
      properties[:measure][:key]
    end
  end
end
