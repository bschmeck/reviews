# frozen_string_literal: true

module Review
  class Directory
    def self.lookup(github_login:)
      person = people.detect { |p| p.github_login == github_login }
      return person if person

      MissingPerson.new(github_login)
    end

    def self.people
      @people ||=
        begin
          hashes = YAML.load_file(ENV.fetch('USERNAME_ALIASES', 'config/people.yml.example'))
          hashes.map { |hash| Person.new(hash) }
        end
    end
  end
end
