require 'spec_helper'

describe URI::BLURI do
  ITEM_URI = 'http://www.businesslink.gov.uk/bdotg/action/detail?type=RESOURCES&itemId=1081912559'
  RCODE_ITEM_URI = 'http://www.businesslink.gov.uk/bdotg/action/detail?type=RESOURCES&r.l1=2&r.l2=3&itemId=1081912559'
  EXPECTED_QUERY = 'itemId=1081912559&type=RESOURCES'

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

  it 'should support scheme' do
    BLURI('http://foo').scheme.should == 'http'
  end
  it 'should support host' do
    BLURI('http://foo').host.should == 'foo'
  end
  it 'should support path' do
    BLURI('http://foo/a/path').path.should == '/a/path'
  end
  it 'should support query' do
    BLURI('http://foo?to=you&you=foo').query.should == 'to=you&you=foo'
  end
  it 'should support mailto:someone@somewhere' do
    BLURI('mailto:me@there.com').to_s.should == 'mailto:me@there.com'
  end
  it 'should correct unencoded ampersands in mailto' do # http://www.faqs.org/rfcs/rfc2368.html
    BLURI('mailto:fruit&veg.newcastle@rpa.gsi.gov.uk').to_s.should == 'mailto:fruit%26veg.newcastle@rpa.gsi.gov.uk'
  end
  it 'should correct trailing spaces' do
    BLURI('http://www.newspapersoc.org.uk ').to_s.should == 'http://www.newspapersoc.org.uk'
  end
  it 'should correct leading spaces' do
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

    it 'should show nil for absent items' do
      @bluri.query_hash[:eerie_flash].should == nil
    end

    it 'indexes the second query string item' do
      @bluri.query_hash['type'].should == 'resource'
    end

    it 'allows setting of the query' do
      @bluri.query = 'furry=really'
      @bluri.to_s.should == 'http://some.com/a/path?furry=really'
    end

    describe 'reordering the query string' do
      it 'allows sorting of the query string by in-place replacement' do
        @bluri.reorder_query_string!(:type, :itemid, :type)
        @bluri.query.should == 'type=resource&itemid=1'
      end

      it 'should bunch repeated items up' do
        bluri = BLURI('http://foo?itemid=1&type=2&itemid=3').reorder_query_string!(:itemid, :type)
        bluri.query.should == 'itemid=1&itemid=3&type=2'
      end

      it "should leave out items that weren't there" do
        bluri = BLURI('http://foo?itemid=1&type=RESOURCE')
        bluri.reorder_query_string!(:granny_smith, :itemid)
        bluri.to_s.should_not include('granny_smith')
      end

      it 'should not add a query string to a URL without one' do
        bluri = BLURI('http://foo')
        bluri.reorder_query_string!(:things)
        bluri.to_s.should == 'http://foo'
      end

      it "should preserve items which weren't mentioned, but at the end" do
        bluri = BLURI('http://foo?q1=1&q2=2&q3=3')
        bluri.reorder_query_string!(:q3, :q1)
        bluri.query.should == 'q3=3&q1=1&q2=2'
      end

      it 'should leave unmentioned singles alone' do
        TOPIC_URI = 'http://www.businesslink.gov.uk/bdotg/action/layer?topicId=1074450344'
        bluri = BLURI(TOPIC_URI)
        bluri.reorder_query_string!(:itemid, :type)
        bluri.to_s.should == TOPIC_URI
      end
    end
  end

  describe 'Deleting parts' do
    it 'should remove specified parts' do
      BLURI('http://foo?q=1&q2=2&q3=3&q4=4').delete_query_keys!(:q2, :q3).
          query.should == 'q=1&q4=4'
    end

    it 'should leave parts not present' do
      BLURI('http://foo?q=1').delete_query_keys!(:not_present).query.should == 'q=1'
    end

    it 'should allow removal of keys matching a regex' do
      BLURI('http://foo?q=1&r1.l=2&r2.r=3&p=2').delete_query_keys_matching! { |k, _| k =~ /r[0-9]\..+/ }.
          query.should == 'q=1&p=2'
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