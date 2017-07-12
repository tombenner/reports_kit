module ReportsKit
  class Cache
    CACHE_PREFIX = 'reports_kit:reports:'

    def self.get(properties, context_record)
      return unless store
      key = self.key(properties, context_record)
      json_string = store.get(key)
      return if json_string.blank?
      ActiveSupport::JSON.decode(json_string)
    end

    def self.set(properties, context_record, data)
      return unless store
      key = self.key(properties, context_record)
      json_string = ActiveSupport::JSON.encode(data)
      store.setex(key, duration, json_string)
    end

    private

    def self.key(properties, context_record)
      key = properties.to_json
      key += "#{context_record.class}#{context_record.id}" if context_record
      key = Digest::MD5.hexdigest(key)
      "#{CACHE_PREFIX}#{key}"
    end

    def self.duration
      @duration ||= ReportsKit.configuration.cache_duration
    end

    def self.store
      @store ||= ReportsKit.configuration.cache_store
    end
  end
end
