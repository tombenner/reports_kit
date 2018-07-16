module ReportsKit
  module Reports
    class InferrableConfiguration
      SUPPORTED_COLUMN_TYPES = [
        :boolean,
        :datetime,
        :date,
        :integer,
        :string,
        :text
      ]

      attr_accessor :inferrable, :inferrable_type, :model_settings

      delegate :key, :expression, :series, to: :inferrable
      delegate :model_class, :settings_from_model, to: :model_settings

      def initialize(inferrable, inferrable_type)
        self.inferrable = inferrable
        self.inferrable_type = inferrable_type
        self.model_settings = ModelSettings.new(series.model_class, inferrable_type, key)
      end

      def configuration_strategy
        if settings_from_model.present?
          :model
        elsif reflection
          :association
        elsif column_type
          :column
        else
          inferrable_type_string = inferrable_type.to_s.singularize
          raise ArgumentError.new("No configuration found on the #{model_class} model for #{inferrable_type_string} with key: '#{key}'")
        end
      end

      def configured_by_association?
        configuration_strategy == :association
      end

      def configured_by_column?
        configuration_strategy == :column
      end

      def configured_by_model?
        configuration_strategy == :model
      end

      def configured_by_time?
        column_type == :datetime || column_type == :date
      end

      def reflection
        model_class.reflect_on_association(expression.to_sym)
      end

      def instance_class
        return reflection.klass if reflection
        nil
      end

      def column
        return unless inferred_settings
        inferred_settings[:column]
      end

      def inferred_settings
        return { column: "#{model_class.table_name}.#{expression}" } if configured_by_column?
        if configured_by_association?
          return inferred_settings_from_belongs_to_or_has_one if inferred_settings_from_belongs_to_or_has_one
          return inferred_settings_from_has_many if inferred_settings_from_has_many
        end
        {}
      end

      def inferred_settings_from_belongs_to_or_has_one
        @inferred_settings_from_belongs_to_or_has_one ||= begin
          return unless reflection.macro.in?([:belongs_to, :has_one])
          through_reflection = reflection.through_reflection
          if through_reflection
            {
              joins: through_reflection.name,
              column: "#{through_reflection.table_name}.#{reflection.source_reflection.foreign_key}"
            }
          else
            {
              column: "#{model_class.table_name}.#{reflection.foreign_key}"
            }
          end
        end
      end

      def inferred_settings_from_has_many
        @inferred_settings_from_has_many ||= begin
          return unless reflection.macro == :has_many
          through_reflection = reflection.through_reflection
          if through_reflection
            {
              joins: through_reflection.name,
              column: "#{through_reflection.table_name}.#{reflection.source_reflection.foreign_key}"
            }
          else
            {
              joins: reflection.name,
              column: "#{reflection.klass.table_name}.#{reflection.klass.primary_key}"
            }
          end
        end
      end

      def column_type
        column_type = model_class.columns_hash[expression.to_s].try(:type)
        return column_type if SUPPORTED_COLUMN_TYPES.include?(column_type)
      end
    end
  end
end
