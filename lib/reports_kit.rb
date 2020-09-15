require 'rails/all'

require 'reports_kit/normalized_params'
require 'reports_kit/base_controller'
require 'reports_kit/cache'
require 'reports_kit/configuration'
require 'reports_kit/engine'
require 'reports_kit/entity'
require 'reports_kit/filters_controller'
require 'reports_kit/form_builder'
require 'reports_kit/helper'
require 'reports_kit/model'
require 'reports_kit/model_configuration'
require 'reports_kit/order'
require 'reports_kit/relative_time'
require 'reports_kit/report_builder'
require 'reports_kit/reports_controller'
require 'reports_kit/utils'
require 'reports_kit/value'
require 'reports_kit/version'

require 'reports_kit/reports/adapters/mysql'
require 'reports_kit/reports/adapters/postgresql'
require 'reports_kit/reports/adapters/mssql'

require 'reports_kit/reports/data/add_table_aggregations'
require 'reports_kit/reports/data/aggregate_composite'
require 'reports_kit/reports/data/aggregate_one_dimension'
require 'reports_kit/reports/data/aggregate_two_dimensions'
require 'reports_kit/reports/data/chart_data_for_data_method'
require 'reports_kit/reports/data/chart_options'
require 'reports_kit/reports/data/format_one_dimension'
require 'reports_kit/reports/data/format_table'
require 'reports_kit/reports/data/format_two_dimensions'
require 'reports_kit/reports/data/generate'
require 'reports_kit/reports/data/generate_for_properties'
require 'reports_kit/reports/data/normalize_properties'
require 'reports_kit/reports/data/populate_one_dimension'
require 'reports_kit/reports/data/populate_two_dimensions'
require 'reports_kit/reports/data/utils'

require 'reports_kit/reports/filter_types/base'
require 'reports_kit/reports/filter_types/boolean'
require 'reports_kit/reports/filter_types/datetime'
require 'reports_kit/reports/filter_types/number'
require 'reports_kit/reports/filter_types/records'
require 'reports_kit/reports/filter_types/string'

require 'reports_kit/reports/abstract_series'
require 'reports_kit/reports/composite_series'
require 'reports_kit/reports/contextual_filter'
require 'reports_kit/reports/dimension'
require 'reports_kit/reports/dimension_with_series'
require 'reports_kit/reports/filter'
require 'reports_kit/reports/filter_with_series'
require 'reports_kit/reports/generate_autocomplete_results'
require 'reports_kit/reports/generate_autocomplete_method_results'
require 'reports_kit/reports/inferrable_configuration'
require 'reports_kit/reports/model_settings'
require 'reports_kit/reports/properties'
require 'reports_kit/reports/properties_to_filter'
require 'reports_kit/reports/series'

module ReportsKit
  def self.configure
    yield(configuration)
  end

  def self.configuration
    @configuration ||= Configuration.new
  end

  def self.parse_date_range(string)
    ReportsKit::Reports::Data::Utils.parse_date_range(string)
  end

  def self.format_date_range(string)
    ReportsKit::Reports::Data::Utils.format_date_range(string)
  end
end
