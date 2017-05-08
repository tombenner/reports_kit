module ReportsKit
  module Reports
    module Data
      class Generate
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
            data = data_for_two_dimensions(measure, dimension, second_dimension)
          else
            data = data_for_one_dimension(measure, dimension)
          end

          ChartOptions.new(data).perform
        end

        private

        def type
          properties[:type] || 'bar'
        end

        def data_for_one_dimension(measure, dimension)
          relation = measure.filtered_relation
          relation = relation.group(dimension.group_expression)
          relation = relation.joins(dimension.group_joins) if dimension.group_joins
          relation = relation.limit(dimension.dimension_instances_limit)
          if dimension.should_be_sorted_by_count?
            relation = relation.order('1 DESC')
          else
            relation = relation.order('2')
          end
          dimension_keys_values = relation.distinct.public_send(*measure.aggregate_function)
          dimension_keys_values = Utils.populate_sparse_values(dimension_keys_values)
          dimension_keys_values.delete(nil)
          dimension_keys_values.delete('')
          Data::OneDimension.new(measure, dimension, dimension_keys_values).perform.merge(type: type)
        end

        def data_for_two_dimensions(measure, dimension, second_dimension)
          relation = measure.filtered_relation
          relation = measure.conditions.call(relation) if measure.conditions
          relation = relation.group(dimension.group_expression, second_dimension.group_expression)

          relation = relation.joins(dimension.group_joins) if dimension.group_joins
          relation = relation.joins(second_dimension.group_joins) if second_dimension.group_joins

          if dimension.should_be_sorted_by_count?
            relation = relation.order('1 DESC')
          else
            relation = relation.order('2')
          end
          dimension_keys_values = relation.count
          limit = dimension.dimension_instances_limit
          if dimension.should_be_sorted_by_count?
            dimension_keys_values = dimension_keys_values.to_a.first(limit)
          else
            dimension_keys_values = dimension_keys_values.to_a.last(limit)
          end
          dimension_keys_values = Hash[dimension_keys_values]
          Data::TwoDimensions.new(dimension, second_dimension, dimension_keys_values).perform.merge(type: type)
        end
      end
    end
  end
end
