# frozen_string_literal: true

module Review
  class Person
    attr_reader :github_login, :slack_username

    def initialize(github_login:, slack_username:, **_)
      @github_login = github_login
      @slack_username = slack_username
    end
  end
end
