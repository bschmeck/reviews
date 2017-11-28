# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Review::SlackUsernameFormatter do
  context 'before the end of the silent period' do
    it 'dots the username' do
      Timecop.travel(2017, 11, 28, 2, 22, 0) do
        expect(described_class.call('username')).to eq 'userna.me'
      end
    end

    it 'dots short usernames' do
      Timecop.travel(2017, 11, 28, 2, 22, 0) do
        expect(described_class.call('Jane')).to eq 'Ja.ne'
        expect(described_class.call('Sam')).to eq 'S.am'
        expect(described_class.call('Jo')).to eq 'J.o'
        expect(described_class.call('进')).to eq '.进'
      end
    end
  end

  context 'after the start of the silent period' do
    it 'dots the username' do
      Timecop.travel(2017, 11, 28, 22, 22, 0) do
        expect(described_class.call('username')).to eq 'userna.me'
      end
    end

    it 'dots short usernames' do
      Timecop.travel(2017, 11, 28, 2, 22, 0) do
        expect(described_class.call('Jane')).to eq 'Ja.ne'
        expect(described_class.call('Sam')).to eq 'S.am'
        expect(described_class.call('Jo')).to eq 'J.o'
        expect(described_class.call('进')).to eq '.进'
      end
    end
  end

  it 'returns the given username' do
    Timecop.travel(2017, 11, 28, 12, 22, 0) do
      expect(described_class.call('username')).to eq 'username'
    end
  end
end
