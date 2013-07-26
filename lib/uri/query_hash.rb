module URI
  ##
  # Extends a hash with query string rendering/semi-indifferent access
  module QueryHash
    def [](key)
      item = super key
      item = super(key.to_s) if item.nil? || item.length == 0
      item.class == Array && item.length == 0 ? nil : item
    end

    def to_s
      keys.map { |key| render_value(key, self[key]) }.join('&')
    end

    ##
    # Creates a new hash populated with the given objects.
    def self.[](value)
      Hash[value].tap do |hash|
        hash.extend(QueryHash)
      end
    end

    private

    def render_value(key, value)
      return nil if value.nil?
      return value.map { |el| render_value(key, el) }.join('&') if value.kind_of? Array
      "#{key}=#{CGI::escape(value)}"
    end
  end
end