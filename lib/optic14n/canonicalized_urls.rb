module Optic14n
  ##
  # Canonicalizes a set of URLs
  class CanonicalizedUrls
    attr_reader :output_set, :seen, :failures, :each

    extend Forwardable

    def_delegators :@output_set, :size

    def initialize(urls, options)
      @urls = urls
      @options = options
    end

    def canonicalize!
      @seen = 0
      @failures = {}
      @output_set = Set.new

      @urls.each do |url|
        begin
          @output_set.add(BLURI(url).canonicalize!(@options))
        rescue StandardError => e
          failures[url] = e
        end
        @seen += 1
      end
    end

    def write(filename)
      File.open(filename, "w") do |file|
        @output_set.each do |url|
          file.puts url
        end
      end
    end

    ##
    # Canonicalize given urls. +options+ will be passed to +BLURI.parse+
    def self.from_urls(urls, options = {})
      CanonicalizedUrls.new(urls, options).tap(&:canonicalize!)
    end
  end
end
