# frozen_string_literal: true

require 'grape'
require 'require_all'
require_all 'app/review'

module Review
  class Endpoints < Grape::API
    mount PullRequest
    mount Webhook
  end
end
