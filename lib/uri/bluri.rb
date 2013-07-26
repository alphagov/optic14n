# encoding: utf-8

module URI
  ##
  # A URI class with a bit extra for messing about with query strings
  #
  class BLURI < URI::HTTP
    PATH_ESCAPE_MAPPINGS = {
      '[' => '%5b',
      ']' => '%5d',
      ',' => '%2c',
      '"' => '%22',
      "'" => '%27',
      '|' => '%7c',
      '!' => '%21',
      '£' => '%c2%a3'
    }

    PATH_UNESCAPE_MAPPINGS = {
      '%7e' => '~',
      '%21' => '!'
    }

    REQUIRE_REGEX_ESCAPE = %w<. | ( ) [ ] { } + \ ^ $ * ?> & PATH_ESCAPE_MAPPINGS.keys

    extend Forwardable

    def_delegators :@uri, :scheme, :path, :host, :host=, :query, :fragment, :to_s

    def initialize(uri_str)
      @uri = ::Addressable::URI.parse(uri_str)
      raise URI::InvalidURIError, "'#{uri_str}' not a valid URI" unless @uri
    end

    def query_hash
      @query_hash ||= CGI::parse(self.query || '').tap do |query_hash|
        # By default, CGI::parse produces lots of arrays. Usually they have a single element
        # in them. That's correct but not terribly usable. Fix it here.
        query_hash.each_pair { |k, v| query_hash[k] = v[0] if v.length == 1 }
        query_hash.extend QueryHash
      end
    end

    def query_hash=(value)
      @query_hash = value
      @uri.query = @query_hash.to_s == '' ? nil : @query_hash.to_s
    end

    def query=(query_str)
      @query_hash = nil
      @uri.query = query_str == '' ? nil : query_str
    end

    def self.parse(uri_str)
      # Deal with known URI spec breaks - leading/trailing spaces and unencoded entities
      if uri_str.is_a? String
        uri_str = uri_str.strip.downcase.gsub(' ', '%20')
        uri_str.gsub!('&', '%26') if uri_str =~ /^mailto:.*&.*/
      end
      BLURI.new(uri_str)
    end

    def has_query?
      %w(http https).include?(@uri.scheme) && query
    end

    def canonicalize!(options = {})
      @uri.scheme = 'http' if @uri.scheme == 'https'

      @uri.path = '' if @uri.path =~ /^*\/$/
      @uri.path.gsub!(BLURI.path_escape_char_regex,   PATH_ESCAPE_MAPPINGS)
      @uri.path.gsub!(BLURI.path_unescape_code_regex, PATH_UNESCAPE_MAPPINGS)

      canonicalize_query!(options)

      @uri.fragment = nil
      self
    end

    def canonicalize_query!(options)
      allow_all = (options[:allow_query] == :all)
      allowed_keys = [options[:allow_query]].flatten.compact unless allow_all

      query_hash.keep_if do |k, _|
        allow_all || (allowed_keys.include?(k) || allowed_keys.include?(k.to_sym))
      end

      self.query_hash = QueryHash[query_hash.sort_by { |k, _| k }]
    end

    ##
    # Generate a regex which matches all characters in PATH_ESCAPE_MAPPINGS
    def self.path_escape_char_regex
      @path_escape_char_regex ||=
          Regexp.new('[' + PATH_ESCAPE_MAPPINGS.keys.map do |char|
            REQUIRE_REGEX_ESCAPE.include?(char) ? "\\#{char}" : char
          end.join + ']')
    end

    ##
    # Generate a regex which matches all escape sequences in PATH_UNESCAPE_MAPPINGS
    def self.path_unescape_code_regex
      @path_unescape_code_regex ||= Regexp.new(
        PATH_UNESCAPE_MAPPINGS.keys.map { |code| "(?:#{code})" }.join('|')
      )
    end
  end
end

module Kernel
  def BLURI(uri_str)
    ::URI::BLURI.parse(uri_str)
  end

  module_function :BLURI
end