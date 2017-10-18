# frozen_string_literal: true

RSpec.describe Review::Alias do
  describe '.for' do
    it 'gives the alias specified in config/alias.yml' do
      expect(described_class.for('Jared-Prime')).to eq 'Jared'
    end

    context 'off hours specified in config/settings.yml' do
      before do
        allow(described_class).to receive(:current_hour) { 64_801 }
      end

      it 'returns true' do
        expect(described_class.for('Jared-Prime')).to eq 'Jar.ed'
      end
    end

    context 'on hours specified in config/settings.yml' do
      before do
        allow(described_class).to receive(:current_hour) { 36_000 }
      end

      it 'returns false' do
        expect(described_class.for('Jared-Prime')).to eq 'Jared'
      end
    end
  end

  describe '.silence?' do
    context 'off hours specified in config/settings.yml' do
      before do
        allow(described_class).to receive(:current_hour) { 64_801 }
      end

      it 'returns true' do
        expect(described_class).to be_silence
      end
    end

    context 'on hours specified in config/settings.yml' do
      before do
        allow(described_class).to receive(:current_hour) { 36_000 }
      end

      it 'returns false' do
        expect(described_class).not_to be_silence
      end
    end
  end

  describe '.silent' do
    it 'places a dot in the name to silence Slack notification' do
      expect(described_class.silent('Jared')).to eq 'Jar.ed'
    end
  end
end
