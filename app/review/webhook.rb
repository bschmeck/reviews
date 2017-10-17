# frozen_string_literal: true

module Review
  class Webhook < Grape::API
    prefix :webhook

    helpers do
      def forward_webhook_post
        if redirect_url
          capture_response
        else
          status 304
          'No action taken'
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
          '/pr/review/approve'
        end
      end
    end

    resource :test do
      post do
        SlackMessage << 'test endpoint accessed at' \
                      & Time.now.utc
      end
    end

    namespace :config do
      resource :useralias do
        params do
          requires :username, type: String
          requires :aliasname, type: String
        end
        post do
          Alias.make(params[:username], params[:aliasname])
        end
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
