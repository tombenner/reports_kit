module ReportsKit
  class ReportBuilder
    include ActionView::Helpers

    attr_accessor :properties

    def initialize(properties)
      self.properties = normalize_properties(properties)
    end

    def check_box(filter_key)
      filter_key = filter_key.to_s
      filter = filters.find { |filter| filter.key == filter_key }
      checked = filter.properties[:criteria][:operator] == 'true'# if filter
      check_box_tag(filter_key, '1', checked, class: 'form-control input-sm')
    end

    def multi_autocomplete(filter_key, placeholder: nil)
      filter_key = filter_key.to_s
      filter = filters.find { |filter| filter.key == filter_key }
      selected = filter.properties[:criteria][:value] if filter && filter.properties[:criteria]
      # TODO: Don't hardcode path
      select_tag(filter_key, nil, class: 'form-control input-sm select2', multiple: 'multiple', data: { placeholder: placeholder, path: "/reports_kit/resources/measures/#{measure.key}/filters/#{filter_key}/autocomplete" })
    end

    def relative_date(filter_key)
      filter_key = filter_key.to_s
      options = Reports::FilterTypes::Datetime::RELATIVE_DATE_OPTIONS.map { |option| [option[:name], option[:string]] }
      filter = filters.find { |filter| filter.key == filter_key }
      selected = filter.properties[:criteria][:value] if filter
      select_tag(filter_key, options_for_select(options, selected), class: 'form-control input-sm')
    end

    private

    def filters
      measure.filters
    end

    def measure
      Reports::Measure.new(properties[:measure])
    end

    def normalize_properties(properties)
      properties = properties.deep_symbolize_keys
      measure = Reports::Measure.new(properties[:measure])
      properties[:measure] = measure.properties_with_filters
      properties
    end
  end
end
