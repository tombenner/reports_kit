ReportsKit.configure do |config|
  config.custom_methods = {
    format_percentage: -> (value) { "#{value.round(0)}%" },
    add_label_suffix: -> (data) {
      data[:entities].each do |entity|
        entity.label = "#{entity.label} Foo" if entity.label
      end
      data
    }
  }
end
