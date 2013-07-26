require 'spec_helper'

describe URI::BLURI do
  it 'should be an HTTP URI' do
    bluri = BLURI('http://some.where.com')
    bluri.should be_a URI::HTTP
  end

  it 'should not allow other schemes' do
    lambda { BLURI('ftp://foo').should raise_error(ArgumentError) }
  end

  it 'should not allow nil' do
    lambda { BLURI(nil) }.should raise_error(URI::InvalidURIError)
  end

  it 'supports scheme' do
    BLURI('http://foo').scheme.should == 'http'
  end
  it 'supports host' do
    BLURI('http://foo').host.should == 'foo'
  end
  it 'supports path' do
    BLURI('http://foo/a/path').path.should == '/a/path'
  end
  it 'supports query' do
    BLURI('http://foo?to=you&you=foo').query.should == 'to=you&you=foo'
  end
  it 'supports fragment' do
    BLURI('http://foo#fragment').fragment.should == 'fragment'
  end
  it 'supports mailto:someone@somewhere' do
    BLURI('mailto:me@there.com').to_s.should == 'mailto:me@there.com'
  end
  it 'corrects unencoded ampersands ins mailto' do # http://www.faqs.org/rfcs/rfc2368.html
    BLURI('mailto:fruit&veg.newcastle@rpa.gsi.gov.uk').to_s.should == 'mailto:fruit%26veg.newcastle@rpa.gsi.gov.uk'
  end
  it 'corrects trailing spaces' do
    BLURI('http://www.newspapersoc.org.uk ').to_s.should == 'http://www.newspapersoc.org.uk'
  end
  it 'corrects leading spaces' do
    BLURI('  http://www.newspapersoc.org.uk').to_s.should == 'http://www.newspapersoc.org.uk'
  end

  describe 'Query string parsing' do
    before do
      @bluri = BLURI('http://some.com/a/path?itemid=1&type=RESOURCE')
    end

    it 'indexes the query string' do
      @bluri.query_hash['itemid'].should == '1'
    end

    it 'allows indexing by symbol' do
      @bluri.query_hash[:itemid].should == '1'
    end

    it 'shows nil for absent items' do
      @bluri.query_hash[:eerie_flash].should == nil
    end

    it 'indexes the second query string item' do
      @bluri.query_hash['type'].should == 'resource'
    end

    it 'allows setting of the query' do
      @bluri.query = 'furry=really'
      @bluri.to_s.should == 'http://some.com/a/path?furry=really'
    end
  end

  describe 'changing query keys' do
    it 'should let us alter parameters' do
      uri = BLURI('http://foo?q=1&r=2')
      uri['q'] = '3'
      uri.to_s.should == 'http://foo?q=3&r=2'
    end
  end
end