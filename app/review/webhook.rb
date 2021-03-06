# frozen_string_literal: true

module Review
  class Webhook < Grape::API
    prefix :webhook

    helpers do
      def forward_webhook_post
        if redirect_url
          capture_response
        else
          "No configuration for `#{params[:action]}`. Dropping payload."
        end
      end

      def capture_response
        JSON.parse(PullRequest
                    .recognize_path(redirect_url)
                    .call(env)
                    .last
                    .body
                    .first)
      end

      def redirect_url
        case params[:action]
        when 'assigned'
          '/pr/assign'
        when 'review_requested'
          '/pr/review/request'
        when 'submitted'
          '/pr/review/submit'
        end
      end
    end

    resource :test do
      post do
        SlackMessage << 'test endpoint accessed at' \
                      & Time.now.utc
      end
    end

    resource :github do
      params do
        requires :pull_request, type: Hash
        requires :action, type: String
      end
      post do
        forward_webhook_post
      end
    end
  end
end
