require 'spec_helper'

describe URI::QueryHash do
  describe 'non-HTML encoded query strings' do
    subject { { 'foo' => nil, 'bar' => nil }.extend URI::QueryHash }

    its(['foo']) { should be_nil }
    its(['bar']) { should be_nil }
    its(:to_s)   { should eql('foo&bar') }
  end
end