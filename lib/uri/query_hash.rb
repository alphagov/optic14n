module URI
  ##
  # Extends a hash with query string reordering/deleting capabilities
  module QueryHash
    def ordered_query_string(*args)
      unmentioned_keys = keys.reject { |key| args.include?(key.to_s) || args.include?(key.to_sym) }
      (
        args.uniq.map { |key| render_value(key, self[key]) }.reject { |i| i.nil? } +
            unmentioned_keys.map { |key| render_value(key, self[key]) }
      ).join('&')
    end

    def delete_keys(*args)
      args.uniq.map { |key| delete(key.to_s) }
      to_s
    end

    def [](key)
      item = super key
      item = super(key.to_s) if item.nil? || item.length == 0
      item.class == Array && item.length == 0 ? nil : item
    end

    def to_s
      keys.map { |key| render_value(key, self[key]) }.join('&')
    end

    private

    def render_value(key, value)
      return nil if value.nil?
      return value.map { |el| render_value(key, el) }.join('&') if value.kind_of? Array
      "#{key}=#{CGI::escape(value)}"
    end
  end
end