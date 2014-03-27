# encoding: utf-8

require 'spec_helper'

describe "Paul's tests, translated from Perl" do
  it 'lowercases URLs' do
    BLURI('http://www.EXAMPLE.COM/Foo/Bar/BAZ').canonicalize!.to_s.should == 'http://www.example.com/foo/bar/baz'
  end

  describe 'protocol' do
    it 'translates protocol to http', reason: 'Reduces our input space, everything public anyway' do
      BLURI('https://www.example.com').canonicalize!.to_s.should == 'http://www.example.com'
    end
  end

  describe 'slashes' do
    it 'drops single trailing slashes' do
      BLURI('http://www.example.com/').canonicalize!.to_s.should == 'http://www.example.com'
    end

    it 'drops multiple trailing slashes' do
      BLURI('http://www.example.com////').canonicalize!.to_s.should == 'http://www.example.com'
    end

    it 'drops multiple trailing slashes on the path' do
      BLURI('http://www.example.com/foo///').canonicalize!.to_s.should == 'http://www.example.com/foo'
    end
  end

  describe 'fragments' do
    it 'drops fragment identifier', reason: 'They won''t be mapped, so are redundant' do
      BLURI('http://www.example.com#foo').canonicalize!.to_s.should == 'http://www.example.com'
    end
    it 'drops fragment identifier and slashes' do
      BLURI('http://www.example.com/#foo').canonicalize!.to_s.should == 'http://www.example.com'
    end
  end

  describe 'Things to keep verbatim or encode', reason: 'http://tools.ietf.org/html/rfc3986' do
    it 'retains colons' do
      BLURI('http://www.example.com/:colon:').canonicalize!.to_s.should == 'http://www.example.com/:colon:'
    end
    it 'retains tilde' do
      BLURI('http://www.example.com/~tilde').canonicalize!.to_s.should == 'http://www.example.com/~tilde'
    end
    it 'retains underscores' do
      BLURI('http://www.example.com/_underscore_').canonicalize!.to_s.should == 'http://www.example.com/_underscore_'
    end
    it 'retains asterisks' do
      BLURI('http://www.example.com/*asterisk*').canonicalize!.to_s.should == 'http://www.example.com/*asterisk*'
    end
    it 'retains parens' do
      BLURI('http://www.example.com/(parens)').canonicalize!.to_s.should == 'http://www.example.com/(parens)'
    end
    it 'escapes square brackets' do
      BLURI('http://www.example.com/[square-brackets]').canonicalize!.to_s.should == 'http://www.example.com/%5bsquare-brackets%5d'
    end
    it 'encodes commas and quotes', reason: 'They make csv harder to awk' do
      BLURI("http://www.example.com/commas,and-\"quotes\"-make-CSV-harder-to-'awk'").canonicalize!.to_s.should ==
          'http://www.example.com/commas%2cand-%22quotes%22-make-csv-harder-to-%27awk%27'
    end
    it 'encodes square brackets and pipes', reason: "It's problematic in curl and regexes" do
      BLURI('http://www.example.com/problematic-in-curl[]||[and-regexes]').canonicalize!.to_s.should ==
          'http://www.example.com/problematic-in-curl%5b%5d%7c%7c%5band-regexes%5d'
    end
    it 'decodes non-reserved characters (! and ~)' do
      # My god, it's full of stars
      BLURI('http://www.example.com/%7eyes%20I%20have%20now%20read%20%5brfc%203986%5d%2C%20%26%20I%27m%20a%20%3Dlot%3D%20more%20reassured%21%21').
          canonicalize!.to_s.should == 'http://www.example.com/~yes%20i%20have%20now%20read%20%5brfc%203986%5d%2c%20%26%20i%27m%20a%20%3dlot%3d%20more%20reassured!!'
    end
    it 'encodes pound signs' do
      BLURI('https://www.example.com/pound-sign-£').canonicalize!.to_s.should == 'http://www.example.com/pound-sign-%c2%a3'
    end
  end

  describe 'query strings' do
    it 'disallows all query string params by default' do
      BLURI('http://www.example.com?q=foo').canonicalize!.to_s.should == 'http://www.example.com'
    end
    it 'disallows all params when there''s a slash' do
      BLURI('http://www.example.com/?q=foo').canonicalize!.to_s.should == 'http://www.example.com'
    end
    it 'disallows all params after a slash with fragid' do
      BLURI('http://www.example.com/?q=foo#bar').canonicalize!.to_s.should == 'http://www.example.com'
    end

    describe 'allowing some or all query string values' do
      it 'allows named query_string parameters' do
        BLURI('http://www.example.com/?q=foo&r=bar').canonicalize!(allow_query: 'q').to_s.should ==
            'http://www.example.com?q=foo'
      end
      it 'sorts query string values' do
        BLURI('http://www.example.com?c=23&d=1&b=909&e=33&a=1').
          canonicalize!(allow_query: [:b,:e,:c,:d,:a]).to_s.should == 'http://www.example.com?a=1&b=909&c=23&d=1&e=33'
      end
      it 'encodes querystring values' do
        BLURI("http://www.example.com?a=you're_dangerous").canonicalize!(allow_query: :all).to_s.should ==
          'http://www.example.com?a=you%27re_dangerous'
      end
      it 'whitelists and sorts query strings' do
        BLURI('http://www.example.com?a=1&c=3&b=2').canonicalize!(allow_query: :all).to_s.should ==
          'http://www.example.com?a=1&b=2&c=3'
      end
      it 'converts matrix URI to query_string' do
        BLURI('http://www.example.com?c=23;d=1;b=909;e=33;a=1').
          canonicalize!(allow_query: [:b,:e,:c,:d,:a]).to_s.should == 'http://www.example.com?a=1&b=909&c=23&d=1&e=33'
      end
      it 'sorts cherry-picked query string arguments' do
        BLURI('http://www.example.com?a=2322sdfsf&topic=334499&q=909&item=23444').
          canonicalize!(allow_query: [:topic, :item]).to_s.should == 'http://www.example.com?item=23444&topic=334499'
      end
      it 'ignores empty querystring values' do
        BLURI('http://www.example.com?a=2322sdfsf&topic=334499&q=909&item=23444').
          canonicalize!(allow_query: %w(foo bar baz)).to_s.should == 'http://www.example.com'
      end

      describe 'querystrings that are not an HTML-encoded thing' do
        before do
          @bluri = BLURI('http://some.com/a/path?foo&bar').canonicalize!(allow_query: :all)
        end

        it 'retains the query string' do
          @bluri.query.should == 'bar&foo'
        end

        it 'has a query hash with empty elements' do
          @bluri.query_hash['foo'].should == nil
          @bluri.query_hash['bar'].should == nil
        end

        it 'renders the string properly' do
          @bluri.query_hash.to_s.should == 'bar&foo'
        end
      end
    end

    describe 'degenerate cases' do
      describe 'the treatment of query strings when there are query string octets that unescape to '\
               'invalid UTF-8 sequences (we no longer treat these as failures)' do
        it 'no longer raises exceptions when there are bad things in query values' do
          BLURI('http://example.com/path?view=%ED').
            canonicalize!(allow_query: :all).
            to_s.should eql('http://example.com/path?view=%ED')
        end

        it 're-encodes correctly when there are bad things in query keys' do
          BLURI('http://example.com/path?%ED=view').
            canonicalize!(allow_query: :all).
            to_s.should eql('http://example.com/path?%ED=view')
        end
      end

      describe 'failure to canonicalize paths correctly' do
        # see https://www.pivotaltracker.com/s/projects/860575/stories/54502932

        subject { BLURI('http://www.voa.gov.uk/stuff/?query=thing').canonicalize!(allow_query: :all) }

        its(:path) { should eql('/stuff') }
        its(:query) { should eql('query=thing') }
      end
    end
  end
end
