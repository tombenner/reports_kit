module ReportsKit
  module Reports
    module Data
      class Utils
        def self.format_display_time(time)
          time.strftime('%b %-d, \'%y')
        end

        def self.format_configuration_time(time)
          time.strftime('%b %-d, %Y')
        end

        def self.format_time_value(value)
          time = RelativeTime.parse(value, prevent_exceptions: true)
          return value unless time
          Utils.format_configuration_time(time)
        end

        def self.parse_date_string(string)
          begin
            Date.parse(string)
          rescue ArgumentError
            RelativeTime.parse(string)
          end
        end

        def self.populate_sparse_hash(hash, dimension:)
          keys = hash.keys
          is_nested = dimension.measure.has_two_dimensions?
          if is_nested
            keys_values = arrays_values_to_nested_hash(hash)
            keys = keys_values.keys
          else
            keys_values = hash
          end

          first_key = dimension.first_key || keys.first
          return hash unless first_key.is_a?(Time) || first_key.is_a?(Date)
          keys_values = keys_values.map do |key, value|
            key = key.to_date if key.is_a?(Time)
            [key, value]
          end.to_h

          keys = populate_sparse_keys(keys, dimension: dimension)
          populated_keys_values = {}
          default_value = is_nested ? {} : 0
          keys.each do |key|
            populated_keys_values[key] = keys_values[key] || default_value
          end
          return nested_hash_to_arrays_values(populated_keys_values) if is_nested
          populated_keys_values
        end

        def self.populate_sparse_keys(keys, dimension:)
          first_key = dimension.first_key || keys.first
          return keys unless first_key.is_a?(Time) || first_key.is_a?(Date)
          first_key = first_key.to_date
          granularity = dimension.granularity

          first_key = first_key.beginning_of_week(ReportsKit.configuration.first_day_of_week) if granularity == 'week'
          keys = keys.sort
          last_key = (dimension.last_key || keys.last).to_date
          last_key = last_key.beginning_of_week(ReportsKit.configuration.first_day_of_week) if granularity == 'week'

          if granularity == 'week'
            beginning_of_current_week = Date.today.beginning_of_week(ReportsKit.configuration.first_day_of_week)
            last_key = [beginning_of_current_week, last_key].compact.max
          end

          date = first_key
          populated_keys = []
          interval = granularity == 'week' ? 1.week : 1.day
          loop do
            populated_keys << date
            break if date >= last_key
            date += interval
          end
          populated_keys
        end

        def self.arrays_values_to_nested_hash(arrays_values)
          nested_hash = {}
          arrays_values.each do |(key1, key2), value|
            nested_hash[key1] ||= {}
            nested_hash[key1][key2] ||= value
          end
          nested_hash
        end

        def self.nested_hash_to_arrays_values(nested_hash)
          arrays_values = {}
          nested_hash.each do |key1, key2s_values|
            if key2s_values.blank?
              arrays_values[[key1, nil]] = 0
              next
            end
            key2s_values.each do |key2, value|
              arrays_values[[key1, key2]] = value
            end
          end
          arrays_values
        end

        def self.dimension_to_dimension_ids_dimension_instances(dimension, dimension_ids)
          return nil unless dimension.instance_class
          dimension_instances = dimension.instance_class.where(id: dimension_ids.uniq)
          dimension_ids_dimension_instances = dimension_instances.map do |dimension_instance|
            [dimension_instance.id, dimension_instance]
          end
          Hash[dimension_ids_dimension_instances]
        end

        def self.dimension_key_to_label(dimension_instance, dimension, ids_dimension_instances)
          label = dimension.key_to_label(dimension_instance)
          return label if label
          return dimension_instance.to_s if dimension.configured_by_column? && dimension.column_type == :integer
          case dimension_instance
          when Time, Date
            Utils.format_display_time(dimension_instance)
          when Fixnum
            raise ArgumentError.new("ids_dimension_instances must be present for Dimension with identifier: #{dimension_instance}") unless ids_dimension_instances
            instance = ids_dimension_instances[dimension_instance.to_i]
            return unless instance
            instance.to_s
          else
            dimension_instance.to_s.gsub(/\.0$/, '')
          end
        end
      end
    end
  end
end
