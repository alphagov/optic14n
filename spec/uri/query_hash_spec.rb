require "spec_helper"

describe URI::QueryHash do
  describe "non-HTML encoded query strings" do
    subject { { "foo" => nil, "bar" => nil }.extend URI::QueryHash }

    describe "['foo']" do
      subject { super()["foo"] }
      it { is_expected.to be_nil }
    end

    describe "['bar']" do
      subject { super()["bar"] }
      it { is_expected.to be_nil }
    end

    describe "#to_s" do
      subject { super().to_s }
      it { is_expected.to eql("foo&bar") }
    end
  end
end
