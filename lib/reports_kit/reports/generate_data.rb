module ReportsKit
  module Reports
    class GenerateData
      ROUND_PRECISION = 3

      attr_accessor :properties, :context_record

      def initialize(properties, context_record: nil)
        self.properties = properties
        self.context_record = context_record
      end

      def perform
        measure_hash = properties[:measure]
        dimension_hashes = properties[:dimensions]
        raise ArgumentError.new('Blank dimensions') if dimension_hashes.blank?

        dimension_hashes = dimension_hashes.values if dimension_hashes.is_a?(Hash) && dimension_hashes.key?('0')

        raise ArgumentError.new('The number of measures must be exactly one') if measure_hash.blank?
        raise ArgumentError.new('The number of dimensions must be 1-2') unless dimension_hashes.length.in?([1, 2])

        measure = Measure.new(measure_hash, context_record: context_record)
        dimension = Dimension.new(dimension_hashes[0], measure: measure)
        second_dimension = Dimension.new(dimension_hashes[1], measure: measure) if dimension_hashes[1]

        if second_dimension
          data_for_two_dimensions(measure, dimension, second_dimension)
        else
          data_for_one_dimension(measure, dimension)
        end
      end

      private

      def display_format
        properties[:display_format] || 'bar'
      end

      def data_for_one_dimension(measure, dimension)
        labels_values = dimension_and_measure_to_labels_values(dimension, measure)
        values = labels_values.map do |label, value|
          {
            x: label,
            y: value
          }
        end
        chart_hash = {
          key: measure.label,
          values: values
        }

        {
          x_label: properties[:x_label],
          y_label: properties[:y_label],
          display_format: display_format,
          chart_data: [chart_hash]
        }
      end

      def data_for_two_dimensions(measure, dimension, second_dimension)
        chart_data = dimensions_and_measure_to_chart_data(measure, dimension, second_dimension)
        {
          x_label: properties[:x_label],
          y_label: properties[:y_label],
          display_format: display_format,
          chart_data: chart_data
        }
      end

      def dimension_and_measure_to_labels_values(dimension, measure)
        relation = measure.filtered_relation
        relation = relation.group(dimension.group_expression)
        relation = relation.joins(dimension.group_joins) if dimension.group_joins
        # relation = call_dimension_conditions(dimension, relation)
        # relation = measure.conditions.call(relation) if measure.conditions
        # relation = relation.limit(dimension.dimension_instances_limit)
        if dimension.should_be_sorted_by_count?
          relation = relation.order('1 DESC')
        else
          relation = relation.order('2')
        end
        dimension_keys_values = relation.distinct.public_send(*measure.aggregate_function)
        dimension_keys_values = populate_sparse_values(dimension_keys_values)
        dimension_keys_values.delete(nil)
        dimension_keys_values.delete('')

        dimension_ids = dimension_keys_values.keys
        dimension_ids_dimension_instances = dimension_to_dimension_ids_dimension_instances(dimension, dimension_ids)

        labels_values = dimension_keys_values.map do |dimension_instance, value|
          dimension_label = dimension_key_to_label(dimension_instance, dimension_ids_dimension_instances, dimension)
          [dimension_label, value.round(ROUND_PRECISION)]
        end
        labels_values
      end

      def dimensions_and_measure_to_chart_data(measure, dimension, nested_dimension)
        relation = measure.filtered_relation
        relation = measure.conditions.call(relation) if measure.conditions
        relation = relation.group(dimension.group_expression, nested_dimension.group_expression)

        relation = relation.joins(dimension.group_joins) if dimension.group_joins
        relation = relation.joins(nested_dimension.group_joins) if nested_dimension.group_joins

        if dimension.should_be_sorted_by_count?
          relation = relation.order('1 DESC')
        else
          relation = relation.order('2')
        end
        dimension_keys_values = relation.count
        key_pairs = dimension_keys_values.keys

        dimension_ids = key_pairs.map(&:first)
        dimension_ids_dimension_instances = dimension_to_dimension_ids_dimension_instances(dimension, dimension_ids)

        nested_dimension_ids = key_pairs.map(&:last)
        nested_dimension_ids_dimension_instances = dimension_to_dimension_ids_dimension_instances(nested_dimension, nested_dimension_ids)

        key_1s_key_2s_values = dimensions_keys_values_to_key_1s_key_2s_values(dimension, dimension_keys_values)
        label_1s_label_2s_values = key_1s_key_2s_values_to_label_1s_label_2s_values(
          key_1s_key_2s_values,
          dimension,
          nested_dimension,
          dimension_ids_dimension_instances,
          nested_dimension_ids_dimension_instances
        )

        chart_items = label_1s_label_2s_values_to_chart_items(label_1s_label_2s_values)
        chart_items
      end

      def dimensions_keys_values_to_key_1s_key_2s_values(dimension, dimension_keys_values)
        key_1s_key_2s_values = {}
        dimension_keys_values.each do |(key_1, key_2), value|
          next if value.zero? || key_1.blank? || key_2.blank?
          key_1s_key_2s_values[key_1] ||= {}
          key_1s_key_2s_values[key_1][key_2] = value.round(ROUND_PRECISION)
        end
        key_1s_key_2s_values = populate_sparse_values(key_1s_key_2s_values, use_first_value_key: true)

        if dimension.should_be_sorted_by_count?
          key_1s_key_2s_values = key_1s_key_2s_values.sort_by do |key_1, key_2s_values|
            key_2s_values.values.sum
          end.reverse
        end
        key_1s_key_2s_values
      end

      def key_1s_key_2s_values_to_label_1s_label_2s_values(key_1s_key_2s_values, dimension, nested_dimension, dimension_ids_dimension_instances, nested_dimension_ids_dimension_instances)
        label_1s_label_2s_values = {}
        key_1s_key_2s_values.each do |key_1, key_2s_values|
          key_2s_values.each do |key_2, value|
            label_1 = dimension_key_to_label(key_1, dimension_ids_dimension_instances, dimension)
            label_2 = dimension_key_to_label(key_2, nested_dimension_ids_dimension_instances, nested_dimension)
            label_1s_label_2s_values[label_1] ||= {}
            label_1s_label_2s_values[label_1][label_2] = value
          end
        end
        limit = dimension.dimension_instances_limit
        if dimension.should_be_sorted_by_count?
          label_1s_label_2s_values = label_1s_label_2s_values.take(limit)
        else
          label_1s_label_2s_values = label_1s_label_2s_values.to_a.last(limit)
        end
        label_1s_label_2s_values
      end

      def label_1s_label_2s_values_to_chart_items(label_1s_label_2s_values)
        chart_items = []
        label_1s_label_2s_values.map! do |label_1, label_2s_values|
          [label_1, label_2s_values]
        end
        all_label1s = label_1s_label_2s_values.map(&:first)
        label_2s_label_1s_values = {}
        label_1s_label_2s_values.each do |label_1, label_2s_values|
          label_2s_values.each do |label_2, value|
            label_2s_label_1s_values[label_2] ||= {}
            label_2s_label_1s_values[label_2][label_1] = value
          end
        end
        label_2s_label_1s_values.each do |label_2, label_1s_values|
          label_1s_values = Hash[label_1s_values]
          values = all_label1s.map do |label_1|
            {
              x: label_1,
              y: label_1s_values[label_1] || 0
            }
          end
          chart_items << {
            key: label_2,
            values: values
          }
        end
        chart_items
      end

      def dimension_to_dimension_ids_dimension_instances(dimension, dimension_ids)
        return nil unless dimension.instance_class
        dimension_instances = dimension.instance_class.where(id: dimension_ids)
        dimension_ids_dimension_instances = dimension_instances.map do |dimension_instance|
          [dimension_instance.id, dimension_instance]
        end
        Hash[dimension_ids_dimension_instances]
      end

      def dimension_key_to_label(dimension_instance, ids_dimension_instances, dimension)
        case dimension_instance
        when Time
          dimension_instance.to_time.to_i * 1000
        when Fixnum
          raise "instance_class maybe not set for Dimension##{dimension.dimension_key}" unless ids_dimension_instances
          instance = ids_dimension_instances[dimension_instance.to_i]
          raise "instance_class not set for Dimension##{dimension.dimension_key}" unless instance
          instance.to_s
        else
          dimension_instance.to_s
        end
      end

      def populate_sparse_values(dimension_keys_values, use_first_value_key: false)
        return dimension_keys_values if dimension_keys_values.blank?
        first_key = dimension_keys_values.first.first
        return dimension_keys_values unless first_key.is_a?(Time)

        beginning_of_current_week = Time.now.utc.beginning_of_week(ReportsKit.configuration.first_day_of_week)
        last_key = dimension_keys_values.to_a.last.first
        last_key = [beginning_of_current_week, last_key].compact.max

        time = first_key
        full_dimension_instances_values = []
        if use_first_value_key
          first_value_key = dimension_keys_values.first.last.keys.first
          blank_value = { first_value_key => 0 }
        else
          blank_value = 0
        end
        loop do
          full_dimension_instances_values << [time, dimension_keys_values[time] || blank_value]
          break if time >= last_key
          time += 1.week
        end
        Hash[full_dimension_instances_values]
      end
    end
  end
end
