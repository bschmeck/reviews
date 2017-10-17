# frozen_string_literal: true

require 'grape'
require 'openssl'
require 'require_all'
require_all 'app/review'

module Review
  class Endpoints < Grape::API
    helpers do
      def signature
        headers['X-Hub-Signature'].split('=').last
      end

      def full_body
        fb = request.body.read
        request.body.rewind
        fb
      end

      def hmac
        OpenSSL::HMAC.hexdigest(
          'sha1', ENV['WEBHOOK_SECRET_TOKEN'], full_body
        )
      end

      def hmac_valid?
        hmac == signature
      end
    end

    before do
      error!(401) unless hmac_valid?
    end

    mount PullRequest
    mount Webhook
  end
end
