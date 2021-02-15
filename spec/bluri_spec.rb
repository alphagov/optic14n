require "spec_helper"

describe URI::BLURI do
  it "should be an HTTP URI" do
    bluri = BLURI("http://some.where.com")
    expect(bluri).to be_a URI::HTTP
  end

  it "should not allow other schemes" do
    expect { BLURI("ftp://foo") }.to raise_error(URI::InvalidURIError)
  end

  it "should not allow nil" do
    expect { BLURI(nil) }.to raise_error(URI::InvalidURIError)
  end

  it "supports scheme" do
    expect(BLURI("http://foo").scheme).to eq("http")
  end
  it "supports host" do
    expect(BLURI("http://foo").host).to eq("foo")
  end
  it "supports path" do
    expect(BLURI("http://foo/a/path").path).to eq("/a/path")
  end
  it "supports query" do
    expect(BLURI("http://foo?to=you&you=foo").query).to eq("to=you&you=foo")
  end
  it "supports fragment" do
    expect(BLURI("http://foo#fragment").fragment).to eq("fragment")
  end
  it "supports mailto:someone@somewhere" do
    expect(BLURI("mailto:me@there.com").to_s).to eq("mailto:me@there.com")
  end
  it "corrects unencoded ampersands ins mailto" do # http://www.faqs.org/rfcs/rfc2368.html
    expect(BLURI("mailto:fruit&veg.newcastle@rpa.gsi.gov.uk").to_s).to eq("mailto:fruit%26veg.newcastle@rpa.gsi.gov.uk")
  end
  it "corrects trailing spaces" do
    expect(BLURI("http://www.newspapersoc.org.uk ").to_s).to eq("http://www.newspapersoc.org.uk")
  end
  it "corrects leading spaces" do
    expect(BLURI("  http://www.newspapersoc.org.uk").to_s).to eq("http://www.newspapersoc.org.uk")
  end

  describe "Query string parsing" do
    context "the query string is of HTML-encoded form k=v&q=p" do
      before do
        @bluri = BLURI("http://some.com/a/path?itemid=1&type=RESOURCE")
      end

      it "indexes the query string" do
        expect(@bluri.query_hash["itemid"]).to eq("1")
      end

      it "allows indexing by symbol" do
        expect(@bluri.query_hash[:itemid]).to eq("1")
      end

      it "shows nil for absent items" do
        expect(@bluri.query_hash[:eerie_flash]).to eq(nil)
      end

      it "indexes the second query string item" do
        expect(@bluri.query_hash["type"]).to eq("resource")
      end

      it "allows setting of the query" do
        @bluri.query = "furry=really"
        expect(@bluri.to_s).to eq("http://some.com/a/path?furry=really")
      end
    end

    context "the querystring is not an HTML-encoded thing" do
      before do
        @bluri = BLURI("http://some.com/a/path?foo&bar")
      end

      it "retains the query string" do
        expect(@bluri.query).to eq("foo&bar")
      end

      it "has a query hash with empty elements" do
        expect(@bluri.query_hash["foo"]).to eq(nil)
        expect(@bluri.query_hash["foo"]).to eq(nil)
      end
    end
  end
end
