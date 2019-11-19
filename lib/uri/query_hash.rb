module URI
  ##
  # Extends a hash with query string rendering/semi-indifferent access
  module QueryHash
    def [](key)
      item = super key
      item = super(key.to_s) if item.nil? || item.empty?
      item.class == Array && item.empty? ? nil : item
    end

    def to_s
      keys.map { |key| render_value(key, self[key]) }.join("&")
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
      case value
      when nil   then key
      when Array then value.map { |el| render_value(key, el) }.join("&")
      else URI.encode_www_form_component(key) << "=" << URI.encode_www_form_component(value)
      end
    end
  end
end
