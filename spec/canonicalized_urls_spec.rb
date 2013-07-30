require 'spec_helper'

describe Optic14n::CanonicalizedUrls do
  describe 'c14nize' do
    let(:test_urls) do
      %w(
        http://www.qhm.mod.uk/portsmouth/leisure/fuel
        http://www.qhm.mod.uk/portsmouth/leisure/lntm?
        http://www.qhm.mod.uk/portsmouth/leisure/lntm?action=view&id=199
        http://unistats.direct.gov.uk/searchResults.do?pname=institutesearchresults&level3Subjects=L3.90%AC10007761%ACFIRSTDEGREE%ACFulltime%AC430%ACNo%AC60%ACYes%AC83%ACNo%ACYes
      )
    end

    context 'options[:allow_query] is false' do
      subject(:c14nizer) { Optic14n::CanonicalizedUrls.from_urls(test_urls, allow_query: false) }

      it { should be_a(Optic14n::CanonicalizedUrls) }

      its(:seen) { should eql(4) }

      describe 'the output set' do
        subject(:output_set) { c14nizer.output_set }

        its(:size) { should eql(3) }

        describe 'the items' do
          subject { output_set.map(&:to_s) }

          it { should include('http://www.qhm.mod.uk/portsmouth/leisure/fuel') }
          it { should include('http://www.qhm.mod.uk/portsmouth/leisure/lntm') }
          it { should include('http://unistats.direct.gov.uk/searchresults.do') }
        end
      end
    end

    context 'options[:allow_query] is :all' do
      subject(:c14nizer) { Optic14n::CanonicalizedUrls.from_urls(test_urls, allow_query: :all) }

      describe 'the output set' do
        subject(:output_set) { c14nizer.output_set }

        its(:size) { should eql(3) }
      end

      describe 'failures' do
        subject(:failures) { c14nizer.failures }

        it { should be_a(Hash) }

        it 'has our last URL and an error' do
          e = failures[test_urls.last]
          e.should be_an(ArgumentError)
        end
      end
    end
  end
end