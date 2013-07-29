require 'spec_helper'

describe Optic14n::CanonicalizedUrls do
  describe 'c14nize' do
    let(:test_urls) do
      %w(
        http://www.qhm.mod.uk/portsmouth/leisure/fuel
        http://www.qhm.mod.uk/portsmouth/leisure/lntm?
        http://www.qhm.mod.uk/portsmouth/leisure/lntm?action=view&id=199
      )
    end

    context 'options[:allow_query] is false' do
      subject(:c14nizer) { Optic14n::CanonicalizedUrls.from_urls(test_urls, allow_query: false) }

      it { should be_a(Optic14n::CanonicalizedUrls) }

      its(:seen) { should eql(3) }

      describe 'the output set' do
        subject(:output_set) { c14nizer.output_set }

        its(:size) { should eql(2) }

        describe 'the items' do
          subject { output_set.map(&:to_s) }

          it { should include('http://www.qhm.mod.uk/portsmouth/leisure/fuel') }
          it { should include('http://www.qhm.mod.uk/portsmouth/leisure/lntm') }
        end
      end
    end

    context 'options[:allow_query] is :all' do
      subject(:c14nizer) { Optic14n::CanonicalizedUrls.from_urls(test_urls, allow_query: :all) }

      describe 'the output set' do
        subject(:output_set) { c14nizer.output_set }

        its(:size) { should eql(3) }
      end
    end
  end
end