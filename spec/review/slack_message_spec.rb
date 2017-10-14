require 'spec_helper'

RSpec.describe Review::SlackMessage do
  describe '.<<' do
    it 'returns a new instance with an initial message' do
      example = described_class << 'hello'

      expect(example.message).to eq 'hello'
    end

    it 'chains nicely with strings' do
      example = described_class << 'hello' \
                                << 'world'

      expect(example.message).to eq 'hello world'
    end
  end

  describe '#<<' do
    let(:example) { described_class.new 'hello' }

    it 'appends to the instance\'s existing message' do
      example << 'world'

      expect(example.message).to eq 'hello world'
    end

    it 'chains nicely with strings' do
      example << 'beautiful' \
              << 'world'
      expect(example.message).to eq 'hello beautiful world'
    end
  end

  describe '#&' do
    let(:example) { described_class.new 'hello' }

    it 'posts to slack' do
      expect(example.&).to eq 'k'
    end

    it 'appends final string before posting' do
      res = example & 'world' 

      expect(res).to eq 'k'
    end

    it 'closes the message for modification' do
      example & 'world'
      
      expect(example).to be_closed
      expect { example << 'hi again' }.to raise_error(Review::SlackMessage::MessageClosed, 'Message closed. Unable to modify.')
      expect { example &  'hi again' }.to raise_error(Review::SlackMessage::MessageClosed, 'Message closed. Unable to modify.')
    end
  end
end