ReportsKit.configure do |config|
  config.custom_methods = {
    format_percentage: -> (value) { "#{value.round(0)}%" },
    add_label_link: -> (data:, properties:, context_record:) {
      data[:entities].each do |entity|
        entity.label = "<a href='#'>#{entity.label}</a> Bar" if entity.label
      end
      data
    },
    add_label_suffix: -> (data:, properties:, context_record:) {
      data[:entities].each do |entity|
        entity.label = "#{entity.label} Foo" if entity.label
      end
      data
    },
    add_context_record_suffix: -> (data:, properties:, context_record:) {
      data[:entities].each do |entity|
        entity.label = "#{entity.label} #{context_record}" if entity.label
      end
      data
    },
    empty_result_set_for_relation: -> (relation) {
      relation.where('0 = 1')
    },
    prepend_column: -> (data:, properties:, context_record:) {
      values = data[:entities].map do |entity|
        value = entity.instance.is_a?(Date) ? entity.instance.mday : nil
        ReportsKit::Value.new(value, value)
      end
      new_dataset = {
        entity: ReportsKit::Entity.new('day_of_month', 'Day of Month', 'day_of_month'),
        values: values
      }
      data[:datasets] = [new_dataset] + data[:datasets]
      data
    },
    all_repo_ids: -> (dimension_keys:, properties:, context_record:) {
      Repo.pluck(:id)
    }
  }
end
