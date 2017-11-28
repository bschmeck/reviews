# frozen_string_literal: true

module Review
  class PullRequest < Grape::API
    prefix :pr
    format :json

    helpers do
      def pull_request_state_verb
        case params[:review][:state]
        when 'approved'
          'has approved'
        when 'changes_requested'
          'has requested changes on'
        else
          'has reviewed'
        end
      end

      def pull_request_submitter
        Directory.lookup github_login: params[:pull_request][:user][:login]
      end

      def assignee
        Directory.lookup github_login: params[:pull_request][:assignee][:login]
      end

      def pull_request
        params[:pull_request][:html_url]
      end

      def reviewer
        Directory.lookup github_login: params[:requested_reviewer][:login]
      end

      def review_submitter
        Directory.lookup github_login: params[:review][:user][:login]
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
          requires :requested_reviewer, type: Hash do
            requires :login, type: String
          end
        end

        post do
          SlackMessage << pull_request_submitter \
                       << 'needs' \
                       << reviewer \
                       << 'to review' \
                        & pull_request
        end
      end

      resource :submit do
        before do
          error!('Self reviews not allowed') if review_submitter == pull_request_submitter
        end

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
                       << pull_request_state_verb \
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
