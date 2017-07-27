ReportsKit.configure do |config|
  config.custom_methods = {
    format_percentage: -> (value) { "#{value.round(0)}%" },
    add_label_suffix: -> (data, context_record) {
      data[:entities].each do |entity|
        entity.label = "#{entity.label} Foo" if entity.label
      end
      data
    },
    add_context_record_suffix: -> (data, context_record) {
      data[:entities].each do |entity|
        entity.label = "#{entity.label} #{context_record}" if entity.label
      end
      data
    }
  }
end
