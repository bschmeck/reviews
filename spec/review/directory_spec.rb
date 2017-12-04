# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Review::Directory do
  # The default directory contains a single person with GH login Jared-Prime and Slack username Jared
  describe '::lookup' do
    it 'returns a person' do
      person = described_class.lookup(github_login: 'Jared-Prime')
      expect(person.slack_username).to eq Review::SlackUsername.new('Jared')
    end

    context "when the specified github login doesn't exist" do
      it 'returns an object with the given login' do
        person = described_class.lookup(github_login: 'missing')
        expect(person.slack_username).to eq Review::SlackUsername.new('missing')
      end
    end
  end
end
