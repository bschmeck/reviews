# frozen_string_literal: true

ENV['WEBHOOK_SECRET_TOKEN'] = '123456'

require './app/review'
require 'pry'
require 'rack/test'
require 'timecop'

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups
  config.example_status_persistence_file_path = 'spec/persisted.dat'
  config.disable_monkey_patching!
  config.warnings = true
  config.order = :random
  Kernel.srand config.seed

  config.before(:each) do
    allow(HTTParty).to receive(:post)
  end

  config.after(:each) do
    Review::Cache.current.clear
  end
end
