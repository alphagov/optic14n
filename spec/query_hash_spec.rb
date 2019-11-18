require 'spec_helper'

describe URI::QueryHash do
  subject(:hash) { {}.extend URI::QueryHash }

  describe '#to_s' do
    subject { super().to_s }
    it { is_expected.to eql('') }
  end

  describe 'setting a value by symbol' do
    before { hash['x'] = '1' }

    describe '[:x]' do
      subject { super()[:x] }
      it { is_expected.to eql('1') }
    end

    describe "['x']" do
      subject { super()['x'] }
      it { is_expected.to eql('1') }
    end

    describe '#to_s' do
      subject { super().to_s }
      it { is_expected.to eql('x=1') }
    end
  end
end