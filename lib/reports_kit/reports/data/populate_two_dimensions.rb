module ReportsKit
  module Reports
    module Data
      class PopulateTwoDimensions
        attr_accessor :serieses, :dimension, :second_dimension, :sparse_serieses_dimension_keys_values

        def initialize(sparse_serieses_dimension_keys_values)
          self.serieses = sparse_serieses_dimension_keys_values.keys
          self.dimension = serieses.first.dimensions[0]
          self.second_dimension = serieses.first.dimensions[1]
          self.sparse_serieses_dimension_keys_values = sparse_serieses_dimension_keys_values
        end

        def perform
          serieses_populated_dimension_keys_values
        end

        private

        def serieses_populated_dimension_keys_values
          serieses_dimension_keys_values = {}
          secondary_keys_sums = Hash.new(0)
          serieses_populated_primary_keys_secondary_keys_values.each do |series, primary_keys_secondary_keys_values|
            primary_keys_secondary_keys_values.each do |primary_key, secondary_keys_values|
              secondary_keys_values.each do |secondary_key, value|
                secondary_keys_sums[secondary_key] += value
              end
            end
          end
          sorted_secondary_keys = secondary_keys_sums.sort_by(&:last).reverse.map(&:first)
          serieses_populated_primary_keys_secondary_keys_values.each do |series, primary_key_secondary_keys_values|
            serieses_dimension_keys_values[series] = {}
            primary_key_secondary_keys_values.each do |primary_key, secondary_keys_values|
              secondary_keys_values = secondary_keys_values.sort_by { |key, _| sorted_secondary_keys.index(key) }
              secondary_keys_values.each do |secondary_key, value|
                dimension_key = [primary_key, secondary_key]
                serieses_dimension_keys_values[series][dimension_key] = value
                secondary_keys_sums[secondary_key] += value
              end
            end
          end
          serieses_dimension_keys_values
        end

        def serieses_populated_primary_keys_secondary_keys_values
          @populated_dimension_keys_values ||= begin
            serieses_populated_primary_keys_secondary_keys_values = {}
            serieses.each do |series|
              serieses_populated_primary_keys_secondary_keys_values[series] = {}
              primary_keys.each do |primary_key|
                serieses_populated_primary_keys_secondary_keys_values[series][primary_key] = {}
                secondary_keys.each do |secondary_key|
                  value = serieses_primary_keys_secondary_keys_values[series][primary_key].try(:[], secondary_key) || 0
                  serieses_populated_primary_keys_secondary_keys_values[series][primary_key][secondary_key] = value
                end
              end
            end
            serieses_populated_primary_keys_secondary_keys_values
          end
        end

        def serieses_primary_keys_secondary_keys_values
          @serieses_primary_keys_secondary_keys_values ||= begin
            serieses_primary_keys_secondary_keys_values = {}
            sparse_serieses_dimension_keys_values.each do |series, dimension_keys_values|
              serieses_primary_keys_secondary_keys_values[series] = {}
              dimension_keys_values.each do |(primary_key, secondary_key), value|
                primary_key = primary_key.to_date if primary_key.is_a?(Time)
                secondary_key = secondary_key.to_date if secondary_key.is_a?(Time)
                serieses_primary_keys_secondary_keys_values[series][primary_key] ||= {}
                serieses_primary_keys_secondary_keys_values[series][primary_key][secondary_key] = value
              end
            end
            serieses_primary_keys_secondary_keys_values
          end
        end

        def dimension_keys
          @dimension_keys ||= sparse_serieses_dimension_keys_values.values.map(&:keys).reduce(&:+).uniq
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
