# frozen_string_literal: true

module Review
  class MissingPerson
    attr_reader :github_login, :slack_username

    def initialize(login)
      @github_login = login
      @slack_username = SlackUsername.new(login)
    end
  end
end
