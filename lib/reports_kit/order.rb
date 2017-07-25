module ReportsKit
  class Order
    attr_accessor :relation, :field, :direction

    VALID_RELATIONS = %w(count dimension1 dimension2)
    VALID_FIELDS = [nil, 'label']
    VALID_DIRECTIONS = %w(asc desc)

    def initialize(relation, field, direction)
      self.relation = relation
      self.field = field
      self.direction = direction
    end

    def self.parse(string)
      string ||= ''
      field_expression, direction = string.to_s.split(/\s+/)
      relation, field = (field_expression || '').split('.')

      relation = relation.presence
      field = field.presence
      direction = direction.presence || 'asc'

      relation = relation.to_i if relation =~ /^\d+$/

      raise ArgumentError.new("Invalid relation: #{relation}") unless VALID_RELATIONS.include?(relation) || relation.is_a?(Fixnum)
      raise ArgumentError.new("Invalid field: #{field}") unless VALID_FIELDS.include?(field)
      raise ArgumentError.new("Invalid direction: #{direction}") unless VALID_DIRECTIONS.include?(direction)

      new(relation, field, direction)
    end
  end
end
