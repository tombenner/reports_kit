module ReportsKit
  class FormBuilder
    include ActionView::Helpers

    DEFAULT_DATE_RANGE_VALUE = ['-2M', 'now']

    attr_accessor :properties, :additional_params, :context_record, :properties_to_filter

    def initialize(properties, additional_params: nil, context_record: nil)
      self.properties = properties.deep_symbolize_keys
      self.additional_params = additional_params
      self.context_record = context_record
      self.properties_to_filter = Reports::PropertiesToFilter.new(properties, context_record: context_record)
    end

    def check_box(filter_key, options = {})
      filter = properties_to_filter.perform(filter_key)
      checked = filter.normalized_properties[:criteria][:value] == 'true'
      check_box_tag(filter_key, '1', checked, options)
    end

    def date_range(filter_key, options = {})
      filter = properties_to_filter.perform(filter_key)
      defaults = { class: 'form-control input-sm date_range_picker' }
      options = defaults.deep_merge(options)
      value = filter.normalized_properties[:criteria][:value].presence
      value ||= default_date_range_value
      text_field_tag(filter_key, value, options)
    end

    def multi_autocomplete(filter_key, options = {})
      filter = properties_to_filter.perform(filter_key)
      reports_kit_path = Rails.application.routes.url_helpers.reports_kit_path
      path = "#{reports_kit_path}reports_kit/filters/#{filter_key}/autocomplete?"
      path += additional_params.to_query if additional_params.present?

      defaults = {
        class: 'form-control input-sm select2',
        multiple: 'multiple',
        data: {
          placeholder: options[:placeholder],
          path: path
        }
      }
      options = defaults.deep_merge(options)
      select_tag(filter_key, nil, options)
    end

    def string_filter(filter_key, options = {})
      filter = properties_to_filter.perform(filter_key)
      defaults = { class: 'form-control input-sm' }
      options = defaults.deep_merge(options)
      text_field_tag(filter_key, filter.normalized_properties[:criteria][:value], options)
    end

    private

    def default_date_range_value
      @default_date_range_value ||= begin
        start_date = Reports::Data::Utils.format_time_value(DEFAULT_DATE_RANGE_VALUE[0])
        end_date = Reports::Data::Utils.format_time_value(DEFAULT_DATE_RANGE_VALUE[1])
        [start_date, Reports::FilterTypes::Datetime::SEPARATOR, end_date].join(' ')
      end
    end
  end
end
