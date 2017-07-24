module ReportsKit
  class ReportBuilder
    include ActionView::Helpers

    DEFAULT_DATE_RANGE_VALUE = ['-2M', 'now']

    attr_accessor :properties, :additional_params

    def initialize(properties, additional_params: nil)
      self.properties = properties.deep_symbolize_keys
      self.additional_params = additional_params
    end

    def check_box(filter_key, options={})
      filter = validate_filter!(filter_key)
      checked = filter.normalized_properties[:criteria][:value] == 'true'
      check_box_tag(filter_key, '1', checked, options)
    end

    def date_range(filter_key, options={})
      filter = validate_filter!(filter_key)
      defaults = { class: 'form-control input-sm date_range_picker' }
      options = defaults.deep_merge(options)
      value = filter.normalized_properties[:criteria][:value].presence
      value ||= default_date_range_value
      text_field_tag(filter_key, value, options)
    end

    def multi_autocomplete(filter_key, options={})
      validate_filter!(filter_key)
      filter = measure_filters.find { |f| f.key == filter_key.to_s }
      reports_kit_path = Rails.application.routes.url_helpers.reports_kit_path
      path = "#{reports_kit_path}reports_kit/resources/measures/#{filter.measure.key}/filters/#{filter_key}/autocomplete?"
      path += additional_params.to_query if additional_params.present?
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
      text_field_tag(filter_key, filter.normalized_properties[:criteria][:value], options)
    end

    private

    def validate_filter!(filter_key)
      filter_key = filter_key.to_s
      filter = filters.find { |f| f.key == filter_key }
      raise ArgumentError.new("A filter with key '#{filter_key}' is not configured in this report") unless filter
      filter
    end

    def filters
      ui_filters + measure_filters
    end

    def measure_filters
      measures.map(&:filters).flatten
    end

    def ui_filters
      return [] if properties[:ui_filters].blank?
      properties[:ui_filters].map do |ui_filter_properties|
        Reports::Filter.new(ui_filter_properties)
      end
    end

    def measures
      Reports::Measure.new_from_properties!(properties, context_record: nil)
    end

    def default_date_range_value
      @default_date_range_value ||= begin
        start_date = Reports::Data::Utils.format_time_value(DEFAULT_DATE_RANGE_VALUE[0])
        end_date = Reports::Data::Utils.format_time_value(DEFAULT_DATE_RANGE_VALUE[1])
        [start_date, Reports::FilterTypes::Datetime::SEPARATOR, end_date].join(' ')
      end
    end
  end
end
