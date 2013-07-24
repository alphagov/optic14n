module URI
  ##
  # A URI class with a bit extra for messing about with query strings
  #
  class BLURI < URI::HTTP
    extend Forwardable

    def_delegators :@uri, :scheme, :path, :host, :host=, :query, :to_s

    def initialize(uri_str)
      @uri = ::Addressable::URI.parse(uri_str)
      raise URI::InvalidURIError, "'#{uri_str}' not a valid URI" unless @uri
    end

    def query_hash
      @query_hash ||
          (
          @query_hash = CGI::parse(self.query)
          @query_hash.each_pair { |k, v| @query_hash[k] = v[0] if v.length == 1 }
          @query_hash.extend QueryHash
          )
    end

    def query=(query_str)
      @query_hash = nil
      @uri.query = query_str
    end

    def self.parse(uri_str)
      # Deal with known URI spec breaks - leading/trailing spaces and unencoded entities
      if uri_str.is_a? String
        uri_str = uri_str.strip.gsub(' ', '%20')
        uri_str.gsub!('&', '%26') if uri_str =~ /^mailto:.*&.*/
      end
      BLURI.new(uri_str)
    end

    def has_query?
      %w{http https}.include?(@uri.scheme) && query
    end

    #
    # Reorder the query string according to symbols or string key values
    # passed in in order
    #
    def reorder_query_string!(*args)
      return self unless has_query?
      self.query = query_hash.ordered_query_string(*args)
      self
    end

    def delete_query_keys!(*args)
      return self unless has_query?
      self.query = query_hash.delete_keys(*args)
      self
    end

    def []=(key, value)
      return self unless has_query?
      query_hash[key] = value
      self.query = query_hash.to_s
      self
    end

    def canonicalize!
      # no-op after removals
      self
    end

    def delete_query_keys_matching!(&block)
      return self unless has_query?
      self.query = query_hash.delete_if(&block).to_s
      self
    end
  end
end

module Kernel
  def BLURI(uri_str)
    ::URI::BLURI.parse(uri_str)
  end

  module_function :BLURI
end