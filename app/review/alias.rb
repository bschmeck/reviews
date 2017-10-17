# frozen_string_literal: true

module Review
  class Alias
    data = YAML.load_file(ENV['USERNAME_ALIASES'])

    ALIASES = data.merge(data.invert)
                  .freeze

    class << self
      def for(username)
        ALIASES.fetch(username, username)
      end
    end
  end
end
