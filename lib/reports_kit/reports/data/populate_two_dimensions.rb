module ReportsKit
  module Reports
    module Data
      class PopulateTwoDimensions
        attr_accessor :measures, :dimension, :second_dimension, :sparse_measures_dimension_keys_values

        def initialize(sparse_measures_dimension_keys_values)
          self.measures = sparse_measures_dimension_keys_values.keys
          self.dimension = measures.first.dimensions[0]
          self.second_dimension = measures.first.dimensions[1]
          self.sparse_measures_dimension_keys_values = sparse_measures_dimension_keys_values
        end

        def perform
          measures_populated_dimension_keys_values
        end

        private

        def measures_populated_dimension_keys_values
          measures_dimension_keys_values = {}
          secondary_keys_sums = Hash.new(0)
          measures_populated_primary_keys_secondary_keys_values.each do |measure, primary_keys_secondary_keys_values|
            primary_keys_secondary_keys_values.each do |primary_key, secondary_keys_values|
              secondary_keys_values.each do |secondary_key, value|
                secondary_keys_sums[secondary_key] += value
              end
            end
          end
          sorted_secondary_keys = secondary_keys_sums.sort_by(&:last).reverse.map(&:first)
          measures_populated_primary_keys_secondary_keys_values.each do |measure, primary_key_secondary_keys_values|
            measures_dimension_keys_values[measure] = {}
            primary_key_secondary_keys_values.each do |primary_key, secondary_keys_values|
              secondary_keys_values = secondary_keys_values.sort_by { |key, _| sorted_secondary_keys.index(key) }
              secondary_keys_values.each do |secondary_key, value|
                dimension_key = [primary_key, secondary_key]
                measures_dimension_keys_values[measure][dimension_key] = value
                secondary_keys_sums[secondary_key] += value
              end
            end
          end
          measures_dimension_keys_values
        end

        def measures_populated_primary_keys_secondary_keys_values
          @populated_dimension_keys_values ||= begin
            measures_populated_primary_keys_secondary_keys_values = {}
            measures.each do |measure|
              measures_populated_primary_keys_secondary_keys_values[measure] = {}
              primary_keys.each do |primary_key|
                measures_populated_primary_keys_secondary_keys_values[measure][primary_key] = {}
                secondary_keys.each do |secondary_key|
                  value = measures_primary_keys_secondary_keys_values[measure][primary_key].try(:[], secondary_key) || 0
                  measures_populated_primary_keys_secondary_keys_values[measure][primary_key][secondary_key] = value
                end
              end
            end
            measures_populated_primary_keys_secondary_keys_values
          end
        end

        def measures_primary_keys_secondary_keys_values
          @measures_primary_keys_secondary_keys_values ||= begin
            measures_primary_keys_secondary_keys_values = {}
            sparse_measures_dimension_keys_values.each do |measure, dimension_keys_values|
              measures_primary_keys_secondary_keys_values[measure] = {}
              dimension_keys_values.each do |(primary_key, secondary_key), value|
                primary_key = primary_key.to_date if primary_key.is_a?(Time)
                secondary_key = secondary_key.to_date if secondary_key.is_a?(Time)
                measures_primary_keys_secondary_keys_values[measure][primary_key] ||= {}
                measures_primary_keys_secondary_keys_values[measure][primary_key][secondary_key] = value
              end
            end
            measures_primary_keys_secondary_keys_values
          end
        end

        def dimension_keys
          @dimension_keys ||= sparse_measures_dimension_keys_values.values.map(&:keys).reduce(&:+).uniq
        end

        def primary_keys
          @primary_keys ||= begin
            keys = Utils.populate_sparse_keys(dimension_keys.map(&:first).uniq, dimension: dimension)
            unless dimension.configured_by_time?
              limit = dimension.dimension_instances_limit
              keys = keys.first(limit) if limit
            end
            keys
          end
        end

        def secondary_keys
          @secondary_keys ||= begin
            keys = Utils.populate_sparse_keys(dimension_keys.map(&:last).uniq, dimension: second_dimension)
            limit = second_dimension.dimension_instances_limit
            keys = keys.first(limit) if limit
            keys
          end
        end
      end
    end
  end
end
