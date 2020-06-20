# frozen_string_literal: true

require 'spiderb/url'

RSpec.describe Spiderb::URL do
  let(:url1) { described_class.of('https://example.com') }
  let(:url1_copy) { described_class.of('https://example.com') }
  let(:url2) { described_class.of('https://example.net') }
  let(:url3) { described_class.of('https://example.org') }

  it 'equals itself in a set' do
    set = Set.new
    set.add(url1)
    set.add(url1_copy)
    expect(set.count).to eq 1
  end

  describe '#eql?' do
    it 'equals an equivalent URL' do
      expect(url1).to eq url1_copy
    end

    it "doesn't equal a different URL" do
      expect(url1).not_to eq url2
    end
  end

  describe '#hash' do
    it 'equals itself' do
      expect(url1.hash).to eq url1_copy.hash
    end

    it "doesn't equal a different URL" do
      expect(url1.hash).not_to eq url2.hash
    end
  end

  describe '#<=>' do
    it 'returns negative for a lesser URL' do
      expect(url2 <=> url3).to be < 0
    end

    it 'returns 0 for an equal URL' do
      expect(url1 <=> url1_copy).to eq 0
    end

    it 'returns positive for a greater URL' do
      expect(url2 <=> url1).to be > 0
    end
  end
end
