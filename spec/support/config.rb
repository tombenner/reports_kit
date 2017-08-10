ReportsKit.configure do |config|
  config.custom_methods = {
    format_percentage: -> (value) { "#{value.round(0)}%" },
    add_label_link: -> (data, context_record) {
      data[:entities].each do |entity|
        entity.label = "<a href='#'>#{entity.label}</a> Bar" if entity.label
      end
      data
    },
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
    },
    empty_result_set_for_relation: -> (relation) {
      relation.where('0 = 1')
    }
  }
end
