module Review
  class PullRequest < Grape::API
    version Review::VERSION
    format :json

    helpers do
      def assignee
        params[:pull_request][:assignee]
      end

      def pull_request
        params[:pull_request][:url]
      end

      def reviewers
        params[:pull_request][:requested_reviewers].lazy.map do |reviewer|
          reviewer[:login]
        end
      end

      def review_submitter
        params[:review][:user][:login]
      end
    end

    resource :assign do
      desc 'notify that a user has been assigned to a PR'
      params do
        requires :pull_request, type: Hash do
          requires :url, type: String
          optional :assignee, type: String
        end
      end

      post do
        m = SlackMessage << assignee \
                         << "has been assigned to"
        m                 & pull_request
      end
    end

    resource :request do
      desc 'notify that one or more users have been asked to review a PR'
      params do
        requires :pull_request, type: Hash do
          requires :url, type: String
          requires :requested_reviewers, type: Array[JSON] do
            requires :login
          end
        end
      end

      post do
        reviewers.each do |reviewer|
          m = SlackMessage << reviewer \
                           << "has been asked to review"
          m                 & pull_request
        end
      end
    end

    resource :approve do
      desc 'notify that a user has approved a PR'
      params do
        requires :pull_request, type: Hash do
          requires :url, type: String
        end
        requires :review, type: Hash do
          requires :state, type: String
          requires :body, type: String
          requires :user, type: Hash do
            requires :login, type: String
          end
        end
      end

      post do
        m = SlackMessage << review_submitter \
                         << "has approved"
        m                 & pull_request
      end
    end
  end
end