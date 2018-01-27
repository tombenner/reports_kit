module ReportsKit
  class ChartDataForDataMethod
    attr_accessor :properties

    def initialize(properties)
      self.properties = properties
    end

    def perform
      klass, method_name = ReportsKit::Utils.string_to_class_method(properties[:data_method], 'data_method')
      returned_data = klass.public_send(method_name, properties)
      format_returned_data(returned_data)
    end

    private

    def format_returned_data(returned_data)
      return [] if returned_data.blank?
      returned_data = returned_data.to_a

      first_key = returned_data.first.first
      if first_key.is_a?(Array) && first_key.length == 2
        format_two_dimensional_returned_data(returned_data)
      else
        {
          labels: returned_data.map(&:first),
          datasets: [
            {
              data: returned_data.map(&:last)
            }
          ]
        }
      end
    end

    def format_two_dimensional_returned_data(returned_data)
      primary_keys_secondary_keys_values = {}
      secondary_keys_primary_keys_values = {}
      secondary_keys = []
      returned_data.each do |(primary_key, secondary_key), value|
        secondary_keys_primary_keys_values[secondary_key] ||= {}
        secondary_keys_primary_keys_values[secondary_key][primary_key] = value
        primary_keys_secondary_keys_values[primary_key] ||= {}
        primary_keys_secondary_keys_values[primary_key][secondary_key] = value
      end
      primary_keys = primary_keys_secondary_keys_values.keys
      datasets = secondary_keys_primary_keys_values.map do |secondary_key, primary_keys_values|
        {
          label: secondary_key,
          data: primary_keys.map { |primary_key| primary_keys_values[primary_key] || 0 }
        }
      end
      {
        labels: primary_keys,
        datasets: datasets
      }
    end
  end
end
