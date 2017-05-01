directory = File.dirname(File.absolute_path(__FILE__))
Dir.glob("#{directory}/reports_kit/*.rb") { |file| require file }

module ReportsKit
end
