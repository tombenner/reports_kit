require 'rails/all'

directory = File.dirname(File.absolute_path(__FILE__))
Dir.glob("#{directory}/reports_kit/*.rb") { |file| require file }
Dir.glob("#{directory}/reports_kit/reports/data/*.rb") { |file| require file }
Dir.glob("#{directory}/reports_kit/reports/filter_types/*.rb") { |file| require file }
Dir.glob("#{directory}/reports_kit/reports/*.rb") { |file| require file }

module ReportsKit
  def self.configure
    yield(configuration)
  end

  def self.configuration
    @configuration ||= Configuration.new
  end
end
