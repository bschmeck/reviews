# frozen_string_literal: true

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

    it 'appends the existing message into a new instance' do
      res = example << 'world'

      expect(example.message).to eq 'hello'
      expect(res.message).to eq 'hello world'
    end

    it 'chains nicely with strings' do
      res = example << 'beautiful' \
                    << 'world'

      expect(example.message).to eq 'hello'
      expect(res.message).to eq 'hello beautiful world'
    end
  end

  describe '#&' do
    before do
      allow_any_instance_of(described_class)
        .to receive(:timestamp)
        .and_return(Time.parse('2017-01-01').utc)
    end

    let(:example) { described_class.new 'hello' }

    it 'posts to slack' do
      res = example.&

      expect(res).to include(
        message: 'Slack message sent',
        contents: 'hello',
        checksum: '2cf24dba5fb0a30e26e83b2ac5b9e29e1b161e5c1fa7425e73043362938b9824',
        sent_at: Time.parse('2017-01-01').utc
      )
    end

    it 'appends final string before posting' do
      res = example & 'world'

      expect(res).to include(
        message: 'Slack message sent',
        contents: 'hello world',
        checksum: 'b94d27b9934d3e08a52e52d7da7dabfac484efe37a5380ee9088f7ace2efcde9',
        sent_at: Time.parse('2017-01-01').utc
      )
    end

    it 'chains nicely with strings' do
      res = example << 'beautiful' \
                     & 'world'

      expect(res).to include(
        message: 'Slack message sent',
        contents: 'hello beautiful world',
        checksum: '9392434f03d57c1ce4271efc018f7f826cd4768f5ae8577bb2540a16923c8612',
        sent_at: Time.parse('2017-01-01').utc
      )
    end

    it 'closes the message for modification' do
      example & 'world'

      expect(example).to be_closed
      expect { example << 'hi again' }
        .to raise_error(Review::SlackMessage::MessageClosed, 'Message closed. Unable to modify.')
      expect { example &  'hi again' }
        .to raise_error(Review::SlackMessage::MessageClosed, 'Message closed. Unable to modify.')
    end
  end

  describe '#+' do
    it 'combines with another instance' do
      original = described_class << 'hello'
      additional = described_class << 'world'
      combination = original + additional

      expect(combination.message).to eq 'hello world'
    end
  end
end
