# frozen_string_literal: true

module Review
  class PullRequest < Grape::API
    prefix :pr
    format :json

    helpers do
      def pull_request_submitter
        params[:pull_request][:user][:login]
      end

      def assignee
        params[:pull_request][:assignee][:login]
      end

      def pull_request
        params[:pull_request][:html_url]
      end

      def reviewers
        params.dig(:pull_request, :requested_reviewers) || []
      end

      def review_submitter
        params[:review][:user][:login]
      end

      def review_message
        params[:review][:body]
      end
    end

    resource :assign do
      desc 'notify that a user has been assigned to a PR'
      params do
        requires :pull_request, type: Hash do
          requires :html_url, type: String
          requires :assignee, type: Hash do
            requires :login, type: String
          end
          requires :user, type: Hash do
            requires :login, type: String
          end
        end
      end
      post do
        SlackMessage << pull_request_submitter \
                     << 'assigned' \
                     << pull_request \
                     << 'to' \
                      & assignee
      end
    end

    namespace :review do
      resource :request do
        desc 'notify that one or more users have been asked to review a PR'
        params do
          requires :pull_request, type: Hash do
            requires :html_url, type: String
            requires :user, type: Hash do
              requires :login, type: String
            end
          end
        end

        post do
          reviewers.map do |reviewer|
            SlackMessage << pull_request_submitter \
                         << 'needs' \
                         << reviewer[:login] \
                         << 'to review' \
                          & pull_request
          end
        end
      end

      resource :approve do
        desc 'notify that a user has approved a PR'
        params do
          requires :pull_request, type: Hash do
            requires :html_url, type: String
            requires :user, type: Hash do
              requires :login, type: String
            end
          end
          requires :review, type: Hash do
            requires :body, type: String
            requires :user, type: Hash do
              requires :login, type: String
            end
          end
        end

        post do
          SlackMessage << review_submitter \
                       << 'has approved' \
                       << pull_request \
                       << 'by' \
                       << pull_request_submitter \
                       << "\n" \
                        & review_message
        end
      end
    end
  end
end
