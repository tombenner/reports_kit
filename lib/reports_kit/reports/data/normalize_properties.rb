module ReportsKit
  module Reports
    module Data
      class NormalizeProperties
        attr_accessor :raw_properties

        def initialize(raw_properties)
          self.raw_properties = raw_properties.dup
        end

        def perform
          context_properties = raw_properties.slice(:context_params, :contextual_filters)
          properties = recursively_normalize_properties(raw_properties)
          populate_context_properties(properties, context_properties: context_properties)
        end

        private

        def normalize_filters(series_properties, ui_filters)
          series_properties[:filters] = series_properties[:filters].map do |filter_properties|
            filter_properties = { key: filter_properties } if filter_properties.is_a?(String)
            key = filter_properties[:key]
            ui_key = filter_properties[:ui_key]
            value = ui_filters[key.to_sym]
            value ||= ui_filters[ui_key.to_sym] if ui_key
            if value
              filter_properties[:criteria] ||= {}
              filter_properties[:criteria][:value] = value
            end
            filter_properties
          end
          series_properties
        end

        def recursively_normalize_properties(properties, ui_filters: nil)
          can_have_nesting = properties[:composite_operator].present? || properties[:series].is_a?(Array)
          ui_filters ||= properties[:ui_filters]
          properties[:series] ||= properties.slice(*Series::VALID_KEYS).presence
          properties[:series] = [properties[:series]] if properties[:series].is_a?(Hash) && properties[:series].present?
          return properties if ui_filters.blank? || properties[:series].blank?
          properties[:series] = properties[:series].map do |series_properties|
            series_properties = recursively_normalize_properties(series_properties, ui_filters: ui_filters) if can_have_nesting
            next(series_properties) if series_properties[:filters].blank?
            normalize_filters(series_properties, ui_filters)
          end
          properties
        end

        def populate_context_properties(properties, context_properties: nil)
          return properties if context_properties.blank? || properties.blank? || properties[:series].blank?
          can_have_nesting = properties[:composite_operator].present? || properties[:series].is_a?(Array)
          properties[:series] = properties[:series].map do |series_properties|
            series_properties = series_properties.merge(context_properties)
            series_properties = populate_context_properties(series_properties, context_properties: context_properties) if can_have_nesting
            series_properties
          end
          properties
        end
      end
    end
  end
end
