require 'spec_helper'

RSpec.describe Review::VERSION do
  it 'gives the version of the API' do
    expect(Review::VERSION).to eq '0.0.1.beta'
  end
end