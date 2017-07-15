ReportsKit.configure do |config|
  config.custom_methods = {
    format_percentage: -> (value) { "#{value}%" }
  }
end
