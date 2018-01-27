module ReportsKit
  class Utils
    def self.string_to_class_method(string, string_identifer)
      class_name, method_name = string.split('.')
      raise ArgumentError.new("The #{string_identifer} value should be a class method with a format of MyClass.my_method") unless class_name && method_name
      klass = class_name.constantize
      raise ArgumentError.new("The #{string_identifer} class (#{class_name}) does not respond to a method named \"#{method_name}\"") unless klass.respond_to?(method_name)
      [klass, method_name]
    end
  end
end
