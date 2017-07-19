require 'rails/all'

require 'reports_kit/base_controller'
require 'reports_kit/cache'
require 'reports_kit/configuration'
require 'reports_kit/engine'
require 'reports_kit/helper'
require 'reports_kit/model'
require 'reports_kit/model_configuration'
require 'reports_kit/order'
require 'reports_kit/relative_time'
require 'reports_kit/report_builder'
require 'reports_kit/resources_controller'
require 'reports_kit/reports_controller'
require 'reports_kit/version'

require 'reports_kit/reports/adapters/mysql'
require 'reports_kit/reports/adapters/postgresql'

require 'reports_kit/reports/data/aggregation'
require 'reports_kit/reports/data/chart_options'
require 'reports_kit/reports/data/entity'
require 'reports_kit/reports/data/format_one_dimension'
require 'reports_kit/reports/data/format_two_dimensions'
require 'reports_kit/reports/data/generate'
require 'reports_kit/reports/data/generate_for_properties'
require 'reports_kit/reports/data/one_dimension'
require 'reports_kit/reports/data/populate_one_dimension'
require 'reports_kit/reports/data/populate_two_dimensions'
require 'reports_kit/reports/data/two_dimensions'
require 'reports_kit/reports/data/utils'
require 'reports_kit/reports/data/value'

require 'reports_kit/reports/filter_types/base'
require 'reports_kit/reports/filter_types/boolean'
require 'reports_kit/reports/filter_types/datetime'
require 'reports_kit/reports/filter_types/number'
require 'reports_kit/reports/filter_types/records'
require 'reports_kit/reports/filter_types/string'

require 'reports_kit/reports/abstract_measure'
require 'reports_kit/reports/aggregation_measure'
require 'reports_kit/reports/dimension'
require 'reports_kit/reports/dimension_with_measure'
require 'reports_kit/reports/filter'
require 'reports_kit/reports/filter_with_measure'
require 'reports_kit/reports/generate_autocomplete_results'
require 'reports_kit/reports/inferrable_configuration'
require 'reports_kit/reports/measure'

module ReportsKit
  def self.configure
    yield(configuration)
  end

  def self.configuration
    @configuration ||= Configuration.new
  end
end
