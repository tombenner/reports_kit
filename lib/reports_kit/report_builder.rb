module ReportsKit
  class ReportBuilder
    include ActionView::Helpers

    attr_accessor :properties, :additional_params

    def initialize(properties, additional_params: nil)
      self.properties = properties.deep_symbolize_keys
      self.properties = normalize_properties(self.properties)
      self.additional_params = additional_params
    end

    def check_box(filter_key, options={})
      filter = validate_filter!(filter_key)
      checked = filter.properties[:criteria][:operator] == 'true'
      check_box_tag(filter_key, '1', checked, options)
    end

    def date_range(filter_key, options={})
      filter = validate_filter!(filter_key)
      defaults = { class: 'form-control input-sm date_range_picker' }
      options = defaults.deep_merge(options)
      text_field_tag(filter_key, filter.properties[:criteria][:value], options)
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
      ui_filters + measure_filters
    end

    def measure_filters
      measures.map(&:filters).reduce(&:+)
    end

    def ui_filters
      return [] if properties[:ui_filters].blank?
      properties[:ui_filters].map do |ui_filter_properties|
        Reports::Filter.new(ui_filter_properties)
      end
    end

    def measures
      hashes = properties[:measure] ? [properties[:measure]] : properties[:measures]
      hashes.map do |measure_properties|
        Reports::Measure.new(measure_properties)
      end
    end

    def normalize_properties(properties)
      properties = properties.dup
      properties.delete(:measure)
      properties[:measures] = measures.map(&:normalized_properties)
      properties
    end
  end
end
