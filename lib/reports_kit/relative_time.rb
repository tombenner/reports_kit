module ReportsKit
  class RelativeTime
    LETTERS_DURATION_METHODS = {
      'y' => :years,
      'M' => :months,
      'w' => :weeks,
      'd' => :days,
      'h' => :hours,
      'm' => :minutes,
      's' => :seconds
    }
    LETTERS = LETTERS_DURATION_METHODS.keys.join

    def self.parse(string, prevent_exceptions: false)
      return Time.zone.now if string == 'now'
      original_string = string
      string = string.to_s.strip
      is_negative = string[0, 1] == '-'
      string = string[1..-1] if is_negative

      result_string = is_negative ? '-' : ''
      result_durations = []

      string.scan(/(\d+)([#{LETTERS}]?)/) do |number, letter|
        result_string += "#{number}#{letter}"
        duration_method = LETTERS_DURATION_METHODS[letter]
        unless duration_method
          return if prevent_exceptions
          raise ArgumentError.new("Invalid duration letter: #{letter.inspect}")
        end
        result_durations << number.to_i.public_send(duration_method)
      end

      if result_string == '-' || result_string != original_string.to_s.strip
        return if prevent_exceptions
        raise ArgumentError.new("Invalid time duration: #{original_string.inspect}")
      end
      duration = result_durations.reduce(&:+)
      is_negative ? duration.ago : duration.from_now
    end
  end
end
