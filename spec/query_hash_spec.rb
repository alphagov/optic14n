require 'spec_helper'

describe URI::QueryHash do
  subject(:hash) { {}.extend URI::QueryHash }

  its(:to_s) { should eql('') }

  describe 'allows setting a value by symbol' do
    before { hash[:x] = '1' }

    its(:to_s) { should eql('x=1') }
  end
end