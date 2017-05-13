module ReportsKit
  class ReportBuilder
    include ActionView::Helpers

    attr_accessor :properties

    def initialize(properties)
      self.properties = normalize_properties(properties)
    end

    def check_box(filter_key)
      filter = validate_filter!(filter_key)
      checked = filter.properties[:criteria][:operator] == 'true'
      check_box_tag(filter_key, '1', checked, class: 'form-control input-sm')
    end

    def date_range(filter_key, options={})
      filter = validate_filter!(filter_key)
      defaults = { class: 'form-control input-sm date_range_picker' }
      options = defaults.deep_merge(options)
      text_field_tag(filter_key, filter.properties[:criteria][:value], options)
    end

    def multi_autocomplete(filter_key, options={})
      validate_filter!(filter_key)
      reports_kit_path = Rails.application.routes.url_helpers.reports_kit_path
      path = "#{reports_kit_path}reports_kit/resources/measures/#{measure.key}/filters/#{filter_key}/autocomplete"
      scope = options.delete(:scope)
      params = {}
      params[:scope] = scope if scope.present?

      defaults = {
        class: 'form-control input-sm select2',
        multiple: 'multiple',
        data: {
          placeholder: options[:placeholder],
          path: path,
          params: params
        }
      }
      options = defaults.deep_merge(options)
      select_tag(filter_key, nil, options)
    end

    def string_filter(filter_key, options={})
      filter = validate_filter!(filter_key)
      defaults = { class: 'form-control input-sm' }
      options = defaults.deep_merge(options)
      text_field_tag(filter_key, filter.properties[:criteria][:value], options)
    end

    private

    def validate_filter!(filter_key)
      filter_key = filter_key.to_s
      filter = filters.find { |f| f.key == filter_key }
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
