# frozen_string_literal: true

RSpec.describe Review::Alias do
  describe '.for' do
    it 'gives the alias specified in config/alias.yml' do
      expect(described_class.for('Jared-Prime')).to eq 'Jared'
    end

    context 'off hours specified in config/settings.yml' do
      before do
        allow(described_class).to receive(:current_time_in_seconds) { 64_801 }
      end

      it 'returns true' do
        expect(described_class.for('Jared-Prime')).to eq 'Jar.ed'
      end
    end

    context 'on hours specified in config/settings.yml' do
      before do
        allow(described_class).to receive(:current_time_in_seconds) { 36_000 }
      end

      it 'returns false' do
        expect(described_class.for('Jared-Prime')).to eq 'Jared'
      end
    end
  end

  describe '.silence?' do
    context 'off hours specified in config/settings.yml' do
      before do
        allow(described_class).to receive(:current_time_in_seconds) { 64_801 }
      end

      it 'returns true' do
        expect(described_class).to be_silence
      end
    end

    context 'on hours specified in config/settings.yml' do
      before do
        allow(described_class).to receive(:current_time_in_seconds) { 36_000 }
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

    it 'works for short names' do
      expect(described_class.silent('Jane')).to eq 'Ja.ne'
      expect(described_class.silent('Sam')).to eq 'S.am'
      expect(described_class.silent('Jo')).to eq 'J.o'
      expect(described_class.silent('进')).to eq '.进'
    end
  end
end
