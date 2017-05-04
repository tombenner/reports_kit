module ReportsKit
  class ReportBuilder
    include ActionView::Helpers

    attr_accessor :properties

    def initialize(properties)
      self.properties = normalize_properties(properties)
    end

    def check_box(filter_key)
      filter = filter_for_filter_key(filter_key)
      checked = filter.properties[:criteria][:operator] == 'true'
      check_box_tag(filter_key, '1', checked, class: 'form-control input-sm')
    end

    def multi_autocomplete(filter_key, placeholder: nil)
      filter = filter_for_filter_key(filter_key)
      selected = filter.properties[:criteria][:value] if filter && filter.properties[:criteria]
      # TODO: Don't hardcode path
      select_tag(filter_key, nil, class: 'form-control input-sm select2', multiple: 'multiple', data: { placeholder: placeholder, path: "/reports_kit/resources/measures/#{measure.key}/filters/#{filter_key}/autocomplete" })
    end

    def relative_date(filter_key)
      filter = filter_for_filter_key(filter_key)
      options = Reports::FilterTypes::Datetime::RELATIVE_DATE_OPTIONS.map { |option| [option[:name], option[:string]] }
      selected = filter.properties[:criteria][:value] if filter
      select_tag(filter_key, options_for_select(options, selected), class: 'form-control input-sm')
    end

    def string_filter(filter_key, placeholder: nil)
      filter = filter_for_filter_key(filter_key)
      text_field_tag(filter_key, filter.properties[:criteria][:value], class: 'form-control input-sm', placeholder: placeholder)
    end

    private

    def filter_for_filter_key(filter_key)
      filter_key = filter_key.to_s
      filter = filters.find { |filter| filter.key == filter_key }
      raise ArgumentError.new("A filter with key '#{filter_key}' is not configured in this report") unless filter
      filter
    end

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
